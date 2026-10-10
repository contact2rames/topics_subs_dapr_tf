variable "environment" {
  type = string
  description = "Environment"
}

variable "servicebus_ns" {
  type = string
  description = "Name of azure Service Bus Namespace"
}

variable "rg" {}

variable "container_app_environment" {}

variable "pubsubs-hrw" {
  description = "Dapr Azure Service Bus Topic pubsub components"

  type = map(object({
    topic        = string
    consumer_id  = string
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