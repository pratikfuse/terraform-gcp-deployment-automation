variable "project" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "main_subnet_cidr" {
  type        = string
  default     = "10.0.0.0/20"
  description = "CIDR range for main subnet (internal workloads)"
}

variable "connector_cidr" {
  type        = string
  default     = "10.8.0.0/28"
  description = "CIDR range for VPC Access Connector (Serverless)"
}
