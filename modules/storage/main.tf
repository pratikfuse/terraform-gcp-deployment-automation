resource "google_firestore_database" "default" {
  project         = var.project
  name            = "firestore-db-1"
  location_id     = var.firestore_location
  type            = "FIRESTORE_NATIVE"
  deletion_policy = "ABANDON"
  # destroy the database when terraform delete is calld
  # The deletion needs a 5 minute grace period for the database can be created again
  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      name,
      location_id,
      type
    ]
  }
}


# Cloud Storage bucket for Terraform remote state
resource "google_storage_bucket" "terraform_state" {
  name          = "${var.project}-terraform-state-${var.environment}"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  labels = {
    purpose     = "terraform-state"
    environment = var.environment
  }
}

# Cloud Storage bucket for Cloud Function code
resource "google_storage_bucket" "function_code" {
  name          = "${var.project}-function-code-${var.environment}"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  labels = {
    purpose     = "function-code"
    environment = var.environment
  }
}

