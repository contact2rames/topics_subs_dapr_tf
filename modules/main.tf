data "azurerm_resource_group" "rg" {
  name = var.rg
}

data "azurerm_container_app_environment" "env" {
  name                = var.container_app_environment
  resource_group_name = var.rg
}

# Service Bus Namespace
data "azurerm_servicebus_namespace" "servicebus_ns" {
    name = var.servicebus_ns
    resource_group_name = var.rg
}

# Get Service Bus Primary Connection String
data "azurerm_servicebus_namespace_authorization_rule" "primary" {
  name         = "RootManageSharedAccessKey"
  namespace_id = data.azurerm_servicebus_namespace.servicebus_ns.id
}

# Service Bus Topics
resource "azurerm_servicebus_topic" "topics" {
  for_each = var.topics

  name         = each.value.name
  namespace_id = data.azurerm_servicebus_namespace.servicebus_ns.id

  max_size_in_megabytes       = 1024
  
  default_message_ttl         = "P14D"
  support_ordering            = true
  batched_operations_enabled  = false
  express_enabled             = false
  partitioning_enabled        = false
  requires_duplicate_detection= false

  lifecycle {
  ignore_changes = [
    requires_duplicate_detection
  ]
 }
}


# Flatten topic/subscription structure
locals {
  flattened_subscriptions = flatten([
    for topic_key, topic in var.topics : [
      for sub in topic.subscriptions : {
        topic_key         = topic_key
        subscription_name = sub.name
        filter            = try(sub.filter, null)
        filter_type       = try(sub.filter_type, "SqlFilter")
      }
    ]
  ])
  
}


# Service Bus Topic Subscriptions
resource "azurerm_servicebus_subscription" "subscriptions" {
  for_each = {
    for sub in local.flattened_subscriptions :
    "${sub.topic_key}.${sub.subscription_name}" => sub
  }

  name                = each.value.subscription_name
  topic_id            = azurerm_servicebus_topic.topics[each.value.topic_key].id
  max_delivery_count  = 10
  requires_session    = false
  lock_duration       = "PT2M"
  default_message_ttl = "P7D"

  dead_lettering_on_message_expiration = true
}


# Service Bus Subscription SQL Filters
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

############### dapr components #############
resource "azurerm_container_app_environment_dapr_component" "pubsub" {
  for_each = var.pubsubs-hrw

  name                         = each.key
  container_app_environment_id = data.azurerm_container_app_environment.env.id

  component_type = "pubsub.azure.servicebus.topics"
  version        = "v1"

  metadata {
    name        = "connectionString"
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

