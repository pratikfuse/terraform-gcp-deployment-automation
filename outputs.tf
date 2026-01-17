output "function_url" {
  description = "URL of the deployed Cloud Function"
  value       = module.compute.function_url
}

output "vpc_network_name" {
  description = "Name of the VPC network"
  value       = module.networking.vpc_network
}

# output "function_service_account" {
#   description = "Service account used by Cloud Function"
#   value       = module.iam.function_service_account_email
# }

output "vpc_connector_name" {
  description = "Name of the VPC Access Connector"
  value       = module.networking.serverless_connector
}

output "frontend_url" {
  description = "Frontend url"
  value = module.compute.artifact_registry_repository
}