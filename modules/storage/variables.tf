variable "project" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region for storage resources"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment name (dev, staging, prod)"
}

variable "firestore_location" {
  type        = string
  default     = "us-central1"
  description = "Location for Firestore database"
}

variable "app_engine_location" {
  type        = string
  default     = "us-central"
  description = "Location for App Engine (multi-region)"
}
