# Networking Module Outputs

output "vpc_network" {
  description = "VPC Network name"
  value       = google_compute_network.vpc_network.name
}

output "vpc_network_id" {
  description = "VPC Network ID"
  value       = google_compute_network.vpc_network.id
}

output "main_subnet" {
  description = "Main subnet name"
  value       = google_compute_subnetwork.serverless-subnet.name
}

output "main_subnet_cidr" {
  description = "Main subnet CIDR range"
  value       = google_compute_subnetwork.serverless-subnet.ip_cidr_range
}

output "serverless_connector" {
  description = "Serverless VPC Access Connector name"
  value       = google_vpc_access_connector.serverless-connector.name
}

output "serverless_connector_id" {
  description = "Serverless VPC Access Connector ID"
  value       = google_vpc_access_connector.serverless-connector.id
}
