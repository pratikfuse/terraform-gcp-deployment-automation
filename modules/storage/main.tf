resource "google_firestore_database" "default" {
  project     = var.project
  name        = "(default)"
  location_id = var.firestore_location
  type        = "FIRESTORE_NATIVE"
  
  depends_on = [google_app_engine_app.app]
}

# App Engine app required for Firestore
resource "google_app_engine_app" "app" {
  project       = var.project
  location_id   = var.app_engine_location
  database_type = "CLOUD_FIRESTORE"
}

# Cloud Storage bucket for static website content
resource "google_storage_bucket" "static_content" {
  name          = "${var.project}-static-content-${var.environment}"
  location      = var.region
  force_destroy = true
  
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  labels = {
    purpose = "static-website"
    environment = var.environment
  }
}

# Cloud Storage bucket for Terraform remote state
resource "google_storage_bucket" "terraform_state" {
  name          = "${var.project}-terraform-state-${var.environment}"
  location      = var.region
  force_destroy = false
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }

  labels = {
    purpose = "terraform-state"
    environment = var.environment
  }
}
