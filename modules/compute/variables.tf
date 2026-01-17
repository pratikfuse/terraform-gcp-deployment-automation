variable "project" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region for compute deployment"
}

variable "zone" {
  type        = string
  description = "GCP zone for compute resource"
}


variable "source_bucket" {
  default = "function_source_bucket"

}

variable "source_object" {
  default = ""
}

variable "service_account_email" {
  default = ""
}


variable "function_name" {
  default = "cloud_function_hello_world"
}


variable "entry_point" {
  default = "hello_world"
}

variable "runtime" {
  default = "python310"
}

variable "function_code_bucket" {
  description = "The bucket storage for function code"
}

variable "vpc_connector_id" {
  description = "VPC Connector id for cloud function"
}

variable "cloudrun_service_account_email" {
  description = "Service account email for cloud run"
}

variable "cloud_function_service_account_email" {
  description = "Service account email for cloud function"
}


variable "firestore_database_name" {
  description = "Firestore database name"
}