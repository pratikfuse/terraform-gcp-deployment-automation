resource "google_storage_bucket_object" "function_zip" {
  name           = "hello_api.zip"
  bucket         = var.function_code_bucket
  source         = data.archive_file.function_source.output_path
  # source_hash    = data.archive_file.function_source.output_base64sha256
  depends_on     = [google_project_service.cloud_run]
}


resource "google_project_service" "cloud_run" {
  project = var.project
  service = "run.googleapis.com"
  disable_on_destroy = false
}
resource "google_cloudfunctions2_function" "cloud_function" {
  name     = var.function_name
  location = var.region
  
  labels = {
    "type" = "http" 
  }
  
  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point
    source {
      storage_source {
        bucket = var.function_code_bucket
        object = google_storage_bucket_object.function_zip.name
      }
    }
  }
  
  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
  
  # Force redeploy when source code changes
  depends_on = [google_storage_bucket_object.function_zip]
}

data "archive_file" "function_source" {
  type        = "zip"
  source_dir  = "${path.module}/../../src/hello_api"
  output_path = "${path.module}/function_source.zip"
  
  excludes = [
    ".venv",
    "__pycache__",
    ".pytest_cache",
    "*.pyc",
    ".git",
    "function_source.zip"
  ]
}


resource "google_cloudfunctions2_function_iam_member" "invoker" {
  project        = google_cloudfunctions2_function.cloud_function.project
  location       = google_cloudfunctions2_function.cloud_function.location
  cloud_function = google_cloudfunctions2_function.cloud_function.name
  role = "roles/cloudfunctions.invoker"
  member = "allUsers"
  
}