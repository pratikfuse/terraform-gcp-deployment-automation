output "function_url" {
  description = "URL of the deployed Cloud Function"
  value       = module.compute.function_url
}

output "vpc_network_name" {
  description = "Name of the VPC network"
  value       = module.networking.vpc_network
}

output "vpc_connector_name" {
  description = "Name of the VPC Access Connector"
  value       = module.networking.serverless_connector
}

output "frontend_url" {
  description = "Frontend url"
  value       = module.compute.cloudrun_url
}

output "terraform_state_bucket_name" {
  description = "Name of the Terraform state bucket"
  value       = module.storage.terraform_state_bucket
}