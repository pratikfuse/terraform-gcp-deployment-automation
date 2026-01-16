variable "project" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region for compute deployment"
}

variable "zone" {
    type = string
    description = "GCP zone for compute resource"
}

variable "function_name" {
  default = "rest_api_function"
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
