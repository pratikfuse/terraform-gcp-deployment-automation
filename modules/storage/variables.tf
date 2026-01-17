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
  description = "Environment name (dev, staging, prod)"
}

variable "firestore_location" {
  type        = string
  description = "Location for Firestore database"
}