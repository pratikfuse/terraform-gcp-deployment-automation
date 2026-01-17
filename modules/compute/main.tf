resource "google_storage_bucket_object" "function_zip" {
  name   = "hello_api.zip"
  bucket = var.function_code_bucket
  source = data.archive_file.function_source.output_path
  # source_hash    = data.archive_file.function_source.output_base64sha256
  depends_on = [google_project_service.cloud_run]
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

    service_account_email = var.cloud_function_service_account_email

    vpc_connector                 = var.vpc_connector_id
    vpc_connector_egress_settings = "PRIVATE_RANGES_ONLY"

    environment_variables = {
      FIRESTORE_DATABASE = var.firestore_database_name
    }
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
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"



}


resource "google_project_service" "cloud_run" {
  project            = var.project
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "null_resource" "build_frontend_image" {

  triggers = {
    dockerfile_hash = filemd5("${path.module}/../../src/site/Dockerfile")
    html_hash       = filemd5("${path.module}/../../src/site/index.html")
  }

  provisioner "local-exec" {
    command = <<-EOT
      gcloud builds submit ${path.module}/../../src/frontend \
        --tag=${var.region}-docker.pkg.dev/${var.project}/cloud-run-repo/frontend:latest \
        --project=${var.project}
    EOT
  }

  depends_on = [  ]
}


resource "google_artifact_registry_repository" "frontend-repo" {
  location = var.region
  repository_id = "frontend-repo"
  description = "Docker repo for frontend service"
  format = "DOCKER"
}


resource "google_cloud_run_v2_service" "frontend" {
  name = "frontend-service"
  location = var.region
  project = var.project

  template {
    service_account = var.service_account_email
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project}/frontend-repo/frontend:latest"

      ports {
        container_port = 8080
      }

      env {
        name = "FUNCTION_URL"
        value = google_cloudfunctions2_function.cloud_function.url 
      }

      resources {
        limits = {
          cpu = "1"
          memory = "512Mi"
        }
      }
    }
    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }
    vpc_access {
      connector = var.vpc_connector_id
      egress = "PRIVATE_RANGE_ONLY"
    }
  }
  depends_on = [ null_resource.build_frontend_image ]
}

# VPC configurations for cloud functions
