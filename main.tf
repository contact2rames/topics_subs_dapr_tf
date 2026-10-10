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