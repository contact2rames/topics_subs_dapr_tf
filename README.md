# topics_subs_dapr_tf

A Terraform project for provisioning Azure Service Bus topics, topic subscriptions, and Dapr pub/sub components for Azure Container Apps.

This repository is designed to automate the infrastructure needed for event-driven applications that use Dapr with Azure Service Bus topics. It creates:

- Azure Service Bus topics
- Topic subscriptions and optional SQL filters
- Azure Container Apps Dapr pubsub components using the `pubsub.azure.servicebus.topics` component type
- The infrastructure wiring needed for apps running in an Azure Container Apps environment to publish and consume messages through Dapr

---

## Overview

The project has two main parts:

1. A reusable Terraform module in `modules/` that provisions Azure Service Bus and Dapr resources.
2. A sample environment configuration under `qa/` that calls the module with concrete values.

In practice, the module is intended to support a pattern where:

- an application publishes events to a Dapr topic
- Dapr forwards those events to Azure Service Bus topics
- multiple subscriptions process different message subsets using Service Bus filters
- each subscription is bound to a consumer ID configured in the Dapr component

---

## Repository structure

```text
topics_subs_dapr_tf/
├── modules/
│   ├── main.tf
│   └── variables.tf
├── qa/
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   └── output.tf
├── .gitignore
└── README.md
```

### `modules/`
Contains the Terraform module logic.

This module performs the following actions:

- reads the target Azure resource group
- reads the Azure Container Apps environment
- reads the Azure Service Bus namespace and its authorization rule
- creates Service Bus topics
- creates topic subscriptions
- creates optional SQL filter rules for subscriptions
- creates Dapr pubsub components in the Azure Container Apps environment

### `qa/`
Provides a concrete Terraform environment for deployment. It is effectively the root configuration that consumes the module and supplies real values such as:

- environment name
- Azure resource group
- Container Apps environment name
- Service Bus namespace name
- Service Bus connection string
- topic and subscription definitions
- Dapr pubsub component mapping

---

## What gets created

### Azure Service Bus topics
Each entry in `var.topics` creates an Azure Service Bus topic.

Example topic definition:

```hcl
variable "topics" {
  type = map(object({
    name = string

    subscriptions = list(object({
      name        = string
      filter      = optional(string)
      filter_type = optional(string, "SqlFilter")
    }))
  }))
}
```

The module creates and configures:

- `azurerm_servicebus_topic.topics`
- `azurerm_servicebus_subscription.subscriptions`
- `azurerm_servicebus_subscription_rule.filters`

The subscription rules are created only when a non-empty filter is supplied.

### Dapr pubsub components
The module also creates one or more Dapr pubsub components for Azure Service Bus topics:

```hcl
resource "azurerm_container_app_environment_dapr_component" "pubsub" {
  for_each = var.pubsubs-hrw

  name                         = each.key
  container_app_environment_id = data.azurerm_container_app_environment.env.id

  component_type = "pubsub.azure.servicebus.topics"
  version        = "v1"

  metadata {
    name  = "connectionString"
    value = var.servicebus_connection_string
  }

  metadata {
    name  = "topic"
    value = each.value.topic
  }

  metadata {
    name  = "consumerID"
    value = each.value.consumer_id
  }
}
```

This creates Dapr components compatible with the Azure Service Bus topics pubsub building block.

---

## Terraform inputs

### Root module variables

The module is parameterized by the following variables:

```hcl
variable "environment" {
  type        = string
  description = "Environment"
}

variable "servicebus_ns" {
  type        = string
  description = "Name of azure Service Bus Namespace"
}

variable "rg" {}

variable "container_app_environment" {}

variable "pubsubs-hrw" {
  description = "Dapr Azure Service Bus Topic pubsub components"

  type = map(object({
    topic       = string
    consumer_id = string
  }))
}

variable "topics" {
  type = map(object({
    name = string

    subscriptions = list(object({
      name        = string
      filter      = optional(string)
      filter_type = optional(string, "SqlFilter")
    }))
  }))
}

variable "servicebus_connection_string" {
  description = "Azure Service Bus connection string used by Dapr"
  type        = string
  sensitive   = true
}
```

### `pubsubs-hrw`
This variable maps each Dapr component name to the target Service Bus topic and consumer ID.

Example:

```hcl
pubsubs-hrw = {
  orders-pubsub = {
    topic       = "orders"
    consumer_id = "orders-consumer"
  }
}
```

This results in a Dapr component named `orders-pubsub` configured to use the `orders` Azure Service Bus topic and a Dapr consumer ID of `orders-consumer`.

### `topics`
This variable describes the Service Bus topics and their subscriptions.

Example:

```hcl
topics = {
  orders = {
    name = "orders"
    subscriptions = [
      {
        name   = "orders-created"
        filter = "userId = '123'"
      },
      {
        name = "orders-all"
      }
    ]
  }
}
```

Notes:

- `name` is the Azure Service Bus topic name.
- `subscriptions` is a list of subscription definitions.
- `filter` is optional and, when present, creates a Service Bus SQL filter rule.
- `filter_type` defaults to `SqlFilter` if not specified.

---

## Example usage

The sample configuration in `qa/main.tf` calls the module as follows:

```hcl
module "dapr_components" {
  source = "../modules"

  environment = var.environment
  rg = var.rg
  servicebus_ns = var.servicebus_ns
  topics = var.topics
  servicebus_connection_string = var.servicebus_connection_string
  container_app_environment = var.container_app_environment
  pubsubs-hrw = var.pubsubs-hrw
}
```

The `qa/variables.tf` file defines the input values for a target environment, and the `qa/provider.tf` file configures the Azure provider and remote Terraform state backend.

Example variable values:

```hcl
variable "environment" {
  type = string
  description = "The name of environment"
}

variable "rg" {
  type = string
  description = "The name of the resource group"
}

variable "container_app_environment" {}

variable "servicebus_connection_string" {}

variable "servicebus_ns" {
  type = string
  description = "The name of the servicebus namespace"
}
```

A complete example for the topic and pubsub definitions may look like this:

```hcl
pubsubs-hrw = {
  job-status-events = {
    topic       = "job-status"
    consumer_id = "job-status-service"
  }
}

topics = {
  job-status = {
    name = "job-status"
    subscriptions = [
      {
        name        = "job-status-created"
        filter      = "status = 'created'"
        filter_type = "SqlFilter"
      },
      {
        name = "job-status-all"
      }
    ]
  }
}
```

---

## Deployment workflow

### Prerequisites

Before running Terraform, ensure the following are available:

- Azure subscription access
- Azure CLI login (`az login`)
- Permissions to create or modify:
  - Resource Groups
  - Azure Service Bus namespaces and topics
  - Container Apps environment resources
  - Dapr components in Azure Container Apps
- Terraform installed locally
- A valid Service Bus namespace already exists
- A valid Azure Container Apps environment already exists

### Initialize Terraform

```bash
terraform init
```

### Review planned changes

```bash
terraform  plan
```

### Apply the configuration

```bash
terraform  apply
```

### Destroy the environment

```bash
terraform  destroy
```

## Validate deployed Azure resources

After Terraform has successfully applied the configuration, use the Python validator to confirm that the Service Bus namespace and Container Apps environment exist, that the configured topics and subscriptions are present, and that SQL subscription filters and Dapr component metadata match the expected deployment.

The validator is implemented in [`scripts/validate_azure_resources.py`](./scripts/validate_azure_resources.py). It uses the Azure management SDKs and `DefaultAzureCredential`, so it can use an authenticated Azure CLI session locally or another supported identity in CI. It does not read or print the Service Bus connection string. It only checks that the Dapr component has connection-string metadata configured.

### Prerequisites

- Python 3.10 or later
- An Azure identity with read access to the resource group, Service Bus resources, and Container Apps environment/Dapr components
- Azure CLI installed and authenticated with `az login` if using the Azure CLI credential in the default credential chain
- The Azure subscription ID containing the deployment

Install the Python dependencies from the repository root:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
```

On Linux or macOS, activate the virtual environment with:

```bash
source .venv/bin/activate
```

Create a deployment manifest by copying `validation.example.json` to `validation.json`, then replace the example resource names and topic/subscription/component entries with the values supplied to Terraform. Keep `topics` and `dapr_components` aligned with the Terraform `topics` and `pubsubs-hrw` maps. The `filter` value must exactly match the configured SQL filter; omit it for subscriptions that have no custom filter.

In PowerShell, create the local manifest with:

```powershell
Copy-Item .\validation.example.json .\validation.json
```

The manifest has these fields:

- `resource_group`, `servicebus_namespace`, and `container_app_environment`: names of the existing Azure resources used by the deployment.
- `topics`: each topic name and its subscriptions. Include `filter` for a subscription only when Terraform configures a SQL filter; the validator looks for the module's `SubId` rule.
- `dapr_components`: each component's Azure resource name, `topic`, and `consumer_id`, corresponding to the `pubsubs-hrw` Terraform input.

The example manifest is [`validation.example.json`](./validation.example.json). Do not put credentials or connection strings in the manifest.

Run the validator from the repository root after `terraform apply`:

```powershell
python .\scripts\validate_azure_resources.py `
  --subscription-id "<azure-subscription-id>" `
  --config .\validation.json
```

The script reports each check and exits with:

- `0` when all configured resources and properties pass validation
- `1` when one or more resources are missing or do not match the manifest
- `2` when the manifest is invalid or an Azure request/authentication fails

The identity used by `DefaultAzureCredential` needs permission to read the namespace, topics, subscriptions, rules, Container Apps environment, and Dapr components. The script checks for the module's `SubId` SQL rule when a filter is specified. Dapr checks include component type, version, topic, consumer ID, and the presence (not the value) of connection-string metadata.

---

## How this works with Dapr

This repository is focused on the infrastructure layer for Dapr pub/sub event routing.

A typical app flow is:

1. An app calls Dapr publish API using a component name such as `orders-pubsub`.
2. The Dapr component resolves to the Azure Service Bus topic configured in `metadata.topic`.
3. Azure Service Bus delivers the message to the configured topic.
4. Service Bus subscription logic routes the message to relevant subscription(s) based on filters.
5. Subscriber applications or workers receive messages via their own Dapr bindings or service consumers.

Because the Dapr component uses `component_type = "pubsub.azure.servicebus.topics"`, the configuration matches Azure Service Bus topic-based pubsub behavior and is suitable for event-driven topologies using topic semantics.

---

## Important implementation details

### Service Bus namespace lookup
The module retrieves the target namespace and authorization rule from Azure:

```hcl
data "azurerm_servicebus_namespace" "servicebus_ns" {
  name                = var.servicebus_ns
  resource_group_name = var.rg
}

data "azurerm_servicebus_namespace_authorization_rule" "primary" {
  name         = "RootManageSharedAccessKey"
  namespace_id = data.azurerm_servicebus_namespace.servicebus_ns.id
}
```

This means the project expects a Service Bus namespace created in advance.

### Topic configuration
The topic resource is configured with values such as:

- `max_size_in_megabytes = 1024`
- `default_message_ttl = "P14D"`
- `support_ordering = true`
- `partitioning_enabled = false`
- `requires_duplicate_detection = false`

These settings are deliberately conservative and suitable for many event-driven workloads but may require adjustment based on enterprise requirements.

### Subscription settings
Subscriptions are created with the following defaults:

- `max_delivery_count = 10`
- `lock_duration = "PT2M"`
- `default_message_ttl = "P7D"`
- `dead_lettering_on_message_expiration = true`

This makes the setup resilient to processing issues while still allowing dead-letter handling for expired messages.

### Filter handling
The subscription rules resource creates SQL-based filters only when a non-empty filter is provided:

```hcl
resource "azurerm_servicebus_subscription_rule" "filters" {
  for_each = {
    for sub in local.flattened_subscriptions :
    "${sub.topic_key}.${sub.subscription_name}" => sub
    if try(sub.filter, null) != null && try(sub.filter, "") != ""
  }

  name            = "SubId"
  subscription_id = azurerm_servicebus_subscription.subscriptions[each.key].id

  filter_type = try(each.value.filter_type, "SqlFilter")
  sql_filter  = each.value.filter
}
```

This allows message routing by business rules such as status, region, or tenant.

---

## Security notes

- `servicebus_connection_string` is marked as sensitive.
- The repository uses the Service Bus namespace authorization rule `RootManageSharedAccessKey` for access.
- In production, prefer least-privilege access patterns, scoped service principals, or managed identity-based patterns where possible.
- Avoid committing real connection strings or secrets to source control.

For production-grade deployments, store secrets in Azure Key Vault or another secure secret store and inject them into Terraform at execution time.

---

## Best practices

- Keep topic names consistent with application domains.
- Use subscription filters to reduce unnecessary processing.
- Define consumer IDs clearly per service or worker role.
- Use environment separation such as `dev`, `qa`, `prod` in the Terraform variables.
- Add a central naming convention for topics, subscriptions, and Dapr component names.
- Review dead-lettering policies and message TTL values for your workload.

---

## Notes for this repository

This project is a good fit when you need to:

- create a topic-based Azure Service Bus messaging backbone
- expose that backbone to Dapr applications in Azure Container Apps
- route messages based on subscription filters
- manage the full infrastructure declaratively with Terraform

It is intentionally focused on the infrastructure provisioning side rather than application business logic, so the application code itself is not included in this repository.

---

## Recommended next steps

- Add a `terraform.tfvars` file with environment-specific values.
- Add outputs if you want to surface created resource names or IDs.
- Add additional validation and policy checks for production readiness.
- Consider using Azure Key Vault for sensitive values instead of passing them directly in configuration.
- Expand the repository with app-level Dapr components or subscriber service definitions if needed.

---

## Summary

`topics_subs_dapr_tf` is a Terraform-driven infrastructure template for Azure Service Bus topics and Dapr pub/sub integration in Azure Container Apps. It brings together Azure Service Bus resource creation, topic subscription management, SQL-based message filtering, and Dapr component configuration into a single reusable deployment pattern.
