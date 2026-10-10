variable "environment" {
    type = string
    description = "The name of environment"
}
variable "rg" {
    type = string
    description = "The name of the resource group"
}

variable "container_app_environment" {

}

variable "servicebus_connection_string" {}
variable "servicebus_ns" {
    type = string
    description = "The name of the servicebus namespace"
}


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

