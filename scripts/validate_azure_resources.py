#!/usr/bin/env python3
"""Validate Terraform-managed Azure Service Bus and Dapr resources."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from azure.core.exceptions import AzureError, ResourceNotFoundError
from azure.identity import DefaultAzureCredential
from azure.mgmt.appcontainers import ContainerAppsAPIClient
from azure.mgmt.servicebus import ServiceBusManagementClient


class ValidationReport:
    def __init__(self) -> None:
        self.passed = 0
        self.failed = 0

    def check(self, description: str, valid: bool, detail: str = "") -> None:
        if valid:
            self.passed += 1
            print(f"PASS: {description}")
        else:
            self.failed += 1
            suffix = f" ({detail})" if detail else ""
            print(f"FAIL: {description}{suffix}")

    def missing(self, description: str) -> None:
        self.check(description, False, "resource not found")


def _read_config(path: Path) -> dict[str, Any]:
    try:
        config = json.loads(path.read_text(encoding="utf-8"))
    except OSError as exc:
        raise ValueError(f"Cannot read config file {path}: {exc}") from exc
    except json.JSONDecodeError as exc:
        raise ValueError(f"Invalid JSON in {path}: {exc}") from exc

    if not isinstance(config, dict):
        raise ValueError("The config root must be a JSON object.")

    for field in ("resource_group", "servicebus_namespace", "container_app_environment"):
        if not isinstance(config.get(field), str) or not config[field].strip():
            raise ValueError(f"Config field '{field}' must be a non-empty string.")

    topics = config.get("topics")
    components = config.get("dapr_components")
    if not isinstance(topics, list) or not topics:
        raise ValueError("'topics' must be a non-empty array.")
    if not isinstance(components, list) or not components:
        raise ValueError("'dapr_components' must be a non-empty array.")

    topic_names: set[str] = set()
    for topic in topics:
        if not isinstance(topic, dict) or not isinstance(topic.get("name"), str) or not topic["name"]:
            raise ValueError("Each topic must be an object with a non-empty 'name'.")
        if topic["name"] in topic_names:
            raise ValueError(f"Duplicate topic name: {topic['name']}")
        topic_names.add(topic["name"])
        subscriptions = topic.get("subscriptions")
        if not isinstance(subscriptions, list):
            raise ValueError(f"Topic '{topic['name']}' must have a 'subscriptions' array.")
        subscription_names: set[str] = set()
        for subscription in subscriptions:
            if (
                not isinstance(subscription, dict)
                or not isinstance(subscription.get("name"), str)
                or not subscription["name"]
            ):
                raise ValueError(
                    f"Each subscription for topic '{topic['name']}' must have a non-empty 'name'."
                )
            if subscription["name"] in subscription_names:
                raise ValueError(
                    f"Duplicate subscription '{subscription['name']}' in topic '{topic['name']}'."
                )
            subscription_names.add(subscription["name"])
            if subscription.get("filter") is not None and not isinstance(
                subscription["filter"], str
            ):
                raise ValueError(
                    f"The filter for subscription '{subscription['name']}' must be a string."
                )
            filter_type = subscription.get("filter_type", "SqlFilter")
            if filter_type not in ("SqlFilter", "CorrelationFilter"):
                raise ValueError(
                    f"Unsupported filter_type '{filter_type}' for subscription "
                    f"'{subscription['name']}'."
                )
            if subscription.get("filter") and filter_type != "SqlFilter":
                raise ValueError(
                    f"Subscription '{subscription['name']}' has a filter, but this "
                    "Terraform module configures filter expressions as SQL filters."
                )

    component_names: set[str] = set()
    for component in components:
        if not isinstance(component, dict):
            raise ValueError("Each Dapr component must be a JSON object.")
        for field in ("name", "topic", "consumer_id"):
            if not isinstance(component.get(field), str) or not component[field].strip():
                raise ValueError(f"Each Dapr component must have a non-empty '{field}'.")
        if component["name"] in component_names:
            raise ValueError(f"Duplicate Dapr component name: {component['name']}")
        component_names.add(component["name"])
        if component["topic"] not in topic_names:
            raise ValueError(
                f"Dapr component '{component['name']}' references topic "
                f"'{component['topic']}' which is not listed in 'topics'."
            )

    return config


def _get(value: Any, *names: str) -> Any:
    if isinstance(value, dict):
        for name in names:
            if name in value:
                return value[name]
        return None
    for name in names:
        if hasattr(value, name):
            return getattr(value, name)
    return None


def _metadata_map(metadata: Any) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for item in metadata or []:
        name = _get(item, "name")
        if isinstance(name, str):
            result[name.casefold()] = item
    return result


def _filter_details(rule: Any) -> tuple[str | None, str | None]:
    filter_type = _get(rule, "filter_type", "filterType")
    if hasattr(filter_type, "value"):
        filter_type = filter_type.value
    if isinstance(filter_type, str):
        filter_type = filter_type.rsplit("/", 1)[-1]
    sql_filter = _get(rule, "sql_filter", "sqlFilter")
    expression = _get(sql_filter, "sql_expression", "sqlExpression")
    return filter_type, expression


def validate(subscription_id: str, config: dict[str, Any]) -> int:
    credential = DefaultAzureCredential()
    servicebus = ServiceBusManagementClient(credential, subscription_id)
    container_apps = ContainerAppsAPIClient(credential, subscription_id)
    report = ValidationReport()
    resource_group = config["resource_group"]
    namespace = config["servicebus_namespace"]
    environment = config["container_app_environment"]

    try:
        servicebus.namespaces.get(resource_group, namespace)
        report.check(f"Service Bus namespace '{namespace}' exists", True)
    except ResourceNotFoundError:
        report.missing(f"Service Bus namespace '{namespace}' exists")
        print(f"\nSummary: {report.passed} passed, {report.failed} failed.")
        return 1

    try:
        container_apps.managed_environments.get(resource_group, environment)
        report.check(f"Container Apps environment '{environment}' exists", True)
    except ResourceNotFoundError:
        report.missing(f"Container Apps environment '{environment}' exists")
        print(f"\nSummary: {report.passed} passed, {report.failed} failed.")
        return 1

    for topic in config["topics"]:
        topic_name = topic["name"]
        try:
            servicebus.topics.get(resource_group, namespace, topic_name)
            report.check(f"Topic '{topic_name}' exists", True)
        except ResourceNotFoundError:
            report.missing(f"Topic '{topic_name}' exists")
            continue

        for subscription in topic["subscriptions"]:
            subscription_name = subscription["name"]
            try:
                servicebus.subscriptions.get(
                    resource_group, namespace, topic_name, subscription_name
                )
                report.check(
                    f"Subscription '{subscription_name}' exists on topic '{topic_name}'",
                    True,
                )
            except ResourceNotFoundError:
                report.missing(
                    f"Subscription '{subscription_name}' exists on topic '{topic_name}'"
                )
                continue

            expected_filter = subscription.get("filter")
            if not expected_filter:
                continue

            rule_name = "SubId"
            description = (
                f"SQL filter for subscription '{subscription_name}' on topic '{topic_name}'"
            )
            try:
                rule = servicebus.rules.get(
                    resource_group, namespace, topic_name, subscription_name, rule_name
                )
            except ResourceNotFoundError:
                report.missing(description)
                continue

            filter_type, expression = _filter_details(rule)
            filter_matches = (
                filter_type is not None
                and filter_type.casefold() == "sqlfilter"
                and expression == expected_filter
            )
            report.check(
                description,
                filter_matches,
                f"expected SQL expression {expected_filter!r}, got "
                f"type={filter_type!r}, expression={expression!r}",
            )

    for component in config["dapr_components"]:
        component_name = component["name"]
        description = f"Dapr component '{component_name}' exists"
        try:
            dapr_component = container_apps.dapr_components.get(
                resource_group, environment, component_name
            )
        except ResourceNotFoundError:
            report.missing(description)
            continue

        properties = _get(dapr_component, "properties")
        component_type = _get(properties, "component_type", "componentType")
        version = _get(properties, "version")
        metadata = _metadata_map(_get(properties, "metadata"))

        report.check(description, True)
        report.check(
            f"Dapr component '{component_name}' uses Azure Service Bus topics",
            component_type == "pubsub.azure.servicebus.topics",
            f"got {component_type!r}",
        )
        report.check(
            f"Dapr component '{component_name}' has version 'v1'",
            version == "v1",
            f"got {version!r}",
        )

        expected_metadata = {
            "topic": component["topic"],
            "consumerid": component["consumer_id"],
        }
        for key, expected in expected_metadata.items():
            item = metadata.get(key)
            actual = _get(item, "value") if item is not None else None
            report.check(
                f"Dapr component '{component_name}' metadata '{key}' matches",
                actual == expected,
                f"expected {expected!r}, got {actual!r}",
            )
        report.check(
            f"Dapr component '{component_name}' has connection-string metadata",
            "connectionstring" in metadata,
        )

    print(f"\nSummary: {report.passed} passed, {report.failed} failed.")
    return 1 if report.failed else 0


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Check that the configured Azure Service Bus and Dapr resources exist "
            "and match the deployment manifest."
        )
    )
    parser.add_argument(
        "--subscription-id",
        required=True,
        help="Azure subscription ID containing the deployed resources.",
    )
    parser.add_argument(
        "--config",
        required=True,
        type=Path,
        help="Path to the JSON deployment manifest.",
    )
    args = parser.parse_args()

    try:
        config = _read_config(args.config)
        return validate(args.subscription_id, config)
    except ValueError as exc:
        print(f"Configuration error: {exc}", file=sys.stderr)
        return 2
    except AzureError as exc:
        print(f"Azure request failed: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
