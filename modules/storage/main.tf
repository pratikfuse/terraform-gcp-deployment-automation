resource "google_firestore_database" "default" {
  project     = var.project
  name        = "(default)"
  location_id = var.firestore_location
  type        = "FIRESTORE_NATIVE"
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

resource "google_storage_bucket_object" "static_site_index" {
  name = "index.html"  # name in the bucket
  source = "${path.module}/../../src/site/index.html"  # local path
  bucket = google_storage_bucket.static_content.name
  depends_on = [google_storage_bucket_iam_member.public_rule]
}


resource "google_storage_bucket_object" "static_site_error" {
  name = "error.html"  # name in the bucket
  source = "${path.module}/../../src/site/error.html"  # local path
  bucket = google_storage_bucket.static_content.name
  depends_on = [google_storage_bucket_iam_member.public_rule]
}

resource "google_storage_bucket_iam_member" "public_rule" {
  bucket = google_storage_bucket.static_content.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
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

# Cloud Storage bucket for Cloud Function code
resource "google_storage_bucket" "function_code" {
  name          = "${var.project}-function-code-${var.environment}"
  location      = var.region
  force_destroy = true
  
  uniform_bucket_level_access = true

  labels = {
    purpose = "function-code"
    environment = var.environment
  }
}

