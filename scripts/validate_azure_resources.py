#!/usr/bin/env python3
"""Compare deployed Azure resources with the topic/component inventory CSV."""

from __future__ import annotations

import argparse
import csv
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from azure.core.exceptions import AzureError, ResourceNotFoundError
from azure.identity import DefaultAzureCredential
from azure.mgmt.appcontainers import ContainerAppsAPIClient
from azure.mgmt.servicebus import ServiceBusManagementClient


REPOSITORY_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_INVENTORY = REPOSITORY_ROOT / "topics_subscriptions_dapr_components.csv"
DEFAULT_REPORT = REPOSITORY_ROOT / "azure_validation_report.csv"
REQUIRED_COLUMNS = {
    "record_type",
    "topic_name",
    "subscription_name",
    "filter_type",
    "filter",
    "component_name",
    "component_topic",
    "consumer_id",
}


@dataclass(frozen=True)
class SubscriptionExpectation:
    topic_name: str
    name: str
    filter_type: str
    filter_expression: str


@dataclass(frozen=True)
class ComponentExpectation:
    name: str
    topic: str
    consumer_id: str


@dataclass(frozen=True)
class Inventory:
    topics: tuple[str, ...]
    subscriptions: tuple[SubscriptionExpectation, ...]
    components: tuple[ComponentExpectation, ...]


class ValidationReport:
    fieldnames = (
        "status",
        "resource_type",
        "resource_name",
        "expected",
        "actual",
        "details",
    )

    def __init__(self) -> None:
        self.rows: list[dict[str, str]] = []

    def add(
        self,
        status: str,
        resource_type: str,
        resource_name: str,
        expected: str = "",
        actual: str = "",
        details: str = "",
    ) -> None:
        row = {
            "status": status,
            "resource_type": resource_type,
            "resource_name": resource_name,
            "expected": expected,
            "actual": actual,
            "details": details,
        }
        self.rows.append(row)
        message = f"{status}: {resource_type} '{resource_name}'"
        if details:
            message += f" - {details}"
        print(message)

    def error(self, resource_type: str, resource_name: str, exc: AzureError) -> None:
        self.add("ERROR", resource_type, resource_name, details=str(exc))

    def write(self, path: Path) -> None:
        try:
            with path.open("w", encoding="utf-8-sig", newline="") as report_file:
                writer = csv.DictWriter(report_file, fieldnames=self.fieldnames)
                writer.writeheader()
                writer.writerows(self.rows)
        except OSError as exc:
            raise ValueError(f"Cannot write report file {path}: {exc}") from exc

    @property
    def failures(self) -> int:
        return sum(row["status"] == "FAIL" for row in self.rows)

    @property
    def errors(self) -> int:
        return sum(row["status"] == "ERROR" for row in self.rows)


def _read_inventory(path: Path) -> Inventory:
    try:
        with path.open("r", encoding="utf-8-sig", newline="") as inventory_file:
            reader = csv.DictReader(inventory_file)
            if reader.fieldnames is None:
                raise ValueError(f"Inventory CSV {path} is empty.")
            missing_columns = REQUIRED_COLUMNS.difference(reader.fieldnames)
            if missing_columns:
                raise ValueError(
                    f"Inventory CSV is missing required columns: "
                    f"{', '.join(sorted(missing_columns))}."
                )
            rows = list(reader)
    except OSError as exc:
        raise ValueError(f"Cannot read inventory CSV {path}: {exc}") from exc

    topic_names: set[str] = set()
    subscriptions: list[SubscriptionExpectation] = []
    subscription_keys: set[tuple[str, str]] = set()
    components: list[ComponentExpectation] = []
    component_names: set[str] = set()

    for line_number, row in enumerate(rows, start=2):
        record_type = (row.get("record_type") or "").strip()
        if record_type == "topic_subscription":
            topic_name = (row.get("topic_name") or "").strip()
            subscription_name = (row.get("subscription_name") or "").strip()
            filter_type = (row.get("filter_type") or "").strip()
            filter_expression = row.get("filter") or ""
            if not topic_name or not subscription_name:
                raise ValueError(
                    f"CSV row {line_number}: topic_name and subscription_name "
                    "are required for topic_subscription records."
                )
            if bool(filter_expression) != bool(filter_type):
                raise ValueError(
                    f"CSV row {line_number}: filter and filter_type must either "
                    "both be set or both be blank."
                )
            if filter_expression and filter_type != "SqlFilter":
                raise ValueError(
                    f"CSV row {line_number}: only SqlFilter is supported when "
                    "a filter expression is supplied."
                )
            key = (topic_name, subscription_name)
            if key in subscription_keys:
                raise ValueError(
                    f"CSV row {line_number}: duplicate subscription "
                    f"'{subscription_name}' on topic '{topic_name}'."
                )
            topic_names.add(topic_name)
            subscription_keys.add(key)
            subscriptions.append(
                SubscriptionExpectation(
                    topic_name, subscription_name, filter_type, filter_expression
                )
            )
        elif record_type == "dapr_component":
            name = (row.get("component_name") or "").strip()
            topic = (row.get("component_topic") or "").strip()
            consumer_id = (row.get("consumer_id") or "").strip()
            if not name or not topic or not consumer_id:
                raise ValueError(
                    f"CSV row {line_number}: component_name, component_topic, "
                    "and consumer_id are required for dapr_component records."
                )
            if name in component_names:
                raise ValueError(
                    f"CSV row {line_number}: duplicate Dapr component '{name}'."
                )
            component_names.add(name)
            components.append(ComponentExpectation(name, topic, consumer_id))
        else:
            raise ValueError(
                f"CSV row {line_number}: unsupported record_type {record_type!r}."
            )

    if not topic_names:
        raise ValueError("Inventory CSV contains no topic_subscription records.")
    if not components:
        raise ValueError("Inventory CSV contains no dapr_component records.")

    for component in components:
        if component.topic not in topic_names:
            raise ValueError(
                f"Dapr component '{component.name}' references topic "
                f"'{component.topic}' which is not listed in the inventory."
            )

    return Inventory(
        tuple(sorted(topic_names)),
        tuple(subscriptions),
        tuple(components),
    )


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


def _validate_rule(
    servicebus: ServiceBusManagementClient,
    report: ValidationReport,
    resource_group: str,
    namespace: str,
    subscription: SubscriptionExpectation,
) -> None:
    resource_name = f"{subscription.topic_name}/{subscription.name}/SubId"
    try:
        rule = servicebus.rules.get(
            resource_group,
            namespace,
            subscription.topic_name,
            subscription.name,
            "SubId",
        )
    except ResourceNotFoundError:
        if subscription.filter_expression:
            report.add(
                "FAIL",
                "subscription_filter",
                resource_name,
                expected=f"{subscription.filter_type}: {subscription.filter_expression}",
                actual="not found",
                details="Expected the configured SubId rule.",
            )
        else:
            report.add(
                "PASS",
                "subscription_filter",
                resource_name,
                expected="no custom SubId rule",
                actual="not found",
            )
        return
    except AzureError as exc:
        report.error("subscription_filter", resource_name, exc)
        return

    filter_type, expression = _filter_details(rule)
    if subscription.filter_expression:
        valid = (
            filter_type == subscription.filter_type
            and expression == subscription.filter_expression
        )
        report.add(
            "PASS" if valid else "FAIL",
            "subscription_filter",
            resource_name,
            expected=f"{subscription.filter_type}: {subscription.filter_expression}",
            actual=f"{filter_type}: {expression}",
            details="" if valid else "Filter type or expression does not match the CSV.",
        )
    else:
        report.add(
            "FAIL",
            "subscription_filter",
            resource_name,
            expected="no custom SubId rule",
            actual=f"{filter_type}: {expression}",
            details="A SubId rule exists but the CSV has no filter for this subscription.",
        )


def validate(
    subscription_id: str,
    resource_group: str,
    namespace: str,
    environment: str,
    inventory: Inventory,
    report: ValidationReport,
) -> None:
    credential = DefaultAzureCredential()
    servicebus = ServiceBusManagementClient(credential, subscription_id)
    container_apps = ContainerAppsAPIClient(credential, subscription_id)

    try:
        servicebus.namespaces.get(resource_group, namespace)
        namespace_exists = True
        report.add(
            "PASS",
            "servicebus_namespace",
            namespace,
            expected="exists",
            actual="exists",
        )
    except ResourceNotFoundError:
        namespace_exists = False
        report.add(
            "FAIL",
            "servicebus_namespace",
            namespace,
            expected="exists",
            actual="not found",
        )
    except AzureError as exc:
        namespace_exists = False
        report.error("servicebus_namespace", namespace, exc)

    try:
        container_apps.managed_environments.get(resource_group, environment)
        environment_exists = True
        report.add(
            "PASS",
            "container_apps_environment",
            environment,
            expected="exists",
            actual="exists",
        )
    except ResourceNotFoundError:
        environment_exists = False
        report.add(
            "FAIL",
            "container_apps_environment",
            environment,
            expected="exists",
            actual="not found",
        )
    except AzureError as exc:
        environment_exists = False
        report.error("container_apps_environment", environment, exc)

    topic_results: dict[str, bool] = {}
    for topic_name in inventory.topics:
        if not namespace_exists:
            topic_results[topic_name] = False
            report.add(
                "SKIP",
                "servicebus_topic",
                topic_name,
                details="Cannot check topic because the namespace is unavailable.",
            )
            continue
        try:
            servicebus.topics.get(resource_group, namespace, topic_name)
            topic_results[topic_name] = True
            report.add(
                "PASS",
                "servicebus_topic",
                topic_name,
                expected="exists",
                actual="exists",
            )
        except ResourceNotFoundError:
            topic_results[topic_name] = False
            report.add(
                "FAIL",
                "servicebus_topic",
                topic_name,
                expected="exists",
                actual="not found",
            )
        except AzureError as exc:
            topic_results[topic_name] = False
            report.error("servicebus_topic", topic_name, exc)

    for subscription in inventory.subscriptions:
        resource_name = f"{subscription.topic_name}/{subscription.name}"
        if not topic_results.get(subscription.topic_name, False):
            report.add(
                "SKIP",
                "servicebus_subscription",
                resource_name,
                details="Cannot check subscription because its topic is unavailable.",
            )
            continue
        try:
            servicebus.subscriptions.get(
                resource_group,
                namespace,
                subscription.topic_name,
                subscription.name,
            )
            report.add(
                "PASS",
                "servicebus_subscription",
                resource_name,
                expected="exists",
                actual="exists",
            )
        except ResourceNotFoundError:
            report.add(
                "FAIL",
                "servicebus_subscription",
                resource_name,
                expected="exists",
                actual="not found",
            )
            continue
        except AzureError as exc:
            report.error("servicebus_subscription", resource_name, exc)
            continue
        _validate_rule(
            servicebus, report, resource_group, namespace, subscription
        )

    for component in inventory.components:
        resource_name = component.name
        if not environment_exists:
            report.add(
                "SKIP",
                "dapr_component",
                resource_name,
                details="Cannot check component because the environment is unavailable.",
            )
            continue
        try:
            dapr_component = container_apps.dapr_components.get(
                resource_group, environment, component.name
            )
        except ResourceNotFoundError:
            report.add(
                "FAIL",
                "dapr_component",
                resource_name,
                expected="exists",
                actual="not found",
            )
            continue
        except AzureError as exc:
            report.error("dapr_component", resource_name, exc)
            continue

        properties = _get(dapr_component, "properties")
        report.add(
            "PASS",
            "dapr_component",
            resource_name,
            expected="exists",
            actual="exists",
        )
        component_type = _get(properties, "component_type", "componentType")
        version = _get(properties, "version")
        metadata = _metadata_map(_get(properties, "metadata"))

        expected_type = "pubsub.azure.servicebus.topics"
        report.add(
            "PASS" if component_type == expected_type else "FAIL",
            "dapr_component_type",
            resource_name,
            expected=expected_type,
            actual=str(component_type),
        )
        report.add(
            "PASS" if version == "v1" else "FAIL",
            "dapr_component_version",
            resource_name,
            expected="v1",
            actual=str(version),
        )
        for key, expected in (
            ("topic", component.topic),
            ("consumerid", component.consumer_id),
        ):
            item = metadata.get(key)
            actual = _get(item, "value") if item is not None else None
            valid = actual == expected
            report.add(
                "PASS" if valid else "FAIL",
                f"dapr_metadata_{key}",
                resource_name,
                expected=expected,
                actual="" if actual is None else str(actual),
                details="" if valid else "Metadata value does not match the CSV.",
            )

        has_connection_string = "connectionstring" in metadata
        report.add(
            "PASS" if has_connection_string else "FAIL",
            "dapr_connection_string_metadata",
            resource_name,
            expected="present",
            actual="present" if has_connection_string else "missing",
            details=(
                "The connection-string value is intentionally not read or reported."
                if has_connection_string
                else "The Dapr component has no connectionString metadata."
            ),
        )


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Compare deployed Azure Service Bus and Dapr resources with the "
            "topic/subscription/component inventory CSV."
        )
    )
    parser.add_argument("--subscription-id", required=True)
    parser.add_argument("--resource-group", required=True)
    parser.add_argument("--servicebus-namespace", required=True)
    parser.add_argument("--container-app-environment", required=True)
    parser.add_argument(
        "--inventory",
        type=Path,
        default=DEFAULT_INVENTORY,
        help=f"Inventory CSV (default: {DEFAULT_INVENTORY})",
    )
    parser.add_argument(
        "--report",
        type=Path,
        default=DEFAULT_REPORT,
        help=f"Output CSV report (default: {DEFAULT_REPORT})",
    )
    args = parser.parse_args()

    try:
        inventory = _read_inventory(args.inventory)
        report = ValidationReport()
        validate(
            args.subscription_id,
            args.resource_group,
            args.servicebus_namespace,
            args.container_app_environment,
            inventory,
            report,
        )
        report.write(args.report)
    except ValueError as exc:
        print(f"Configuration or report error: {exc}", file=sys.stderr)
        return 2
    except AzureError as exc:
        print(f"Azure request failed: {exc}", file=sys.stderr)
        return 2

    print(
        f"\nReport: {args.report.resolve()}\n"
        f"Summary: {sum(row['status'] == 'PASS' for row in report.rows)} passed, "
        f"{report.failures} failed, {report.errors} errors, "
        f"{sum(row['status'] == 'SKIP' for row in report.rows)} skipped."
    )
    if report.errors:
        return 2
    return 1 if report.failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
