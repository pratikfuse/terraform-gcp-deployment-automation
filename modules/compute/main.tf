
resource "google_storage_bucket_object" "function_zip" {
  name       = "hello_api.zip"
  bucket     = var.function_code_bucket
  source     = data.archive_file.function_source.output_path
  depends_on = [google_project_service.cloud_run]
}

# Cloud function resource block 
resource "google_cloudfunctions2_function" "cloud_function" {
  name     = "${var.function_name}-${var.environment}"
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
    ingress_settings              = "ALLOW_ALL"

    environment_variables = {
      FIRESTORE_DATABASE = var.firestore_database_name
    }
  }

  depends_on = [google_storage_bucket_object.function_zip]
}

# The hello_api directory is used to deploy the function
data "archive_file" "function_source" {
  type        = "zip"
  source_dir  = "${path.module}/../../src/hello_api"
  output_path = "${path.module}/function_source.zip"

  # remove unused files before bundling zip file
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

# builds frontend image using the tpl template file and Dockerfile containing an nginx service to serve the frontend
resource "null_resource" "build_frontend_image" {

  triggers = {
    dockerfile_hash = filemd5("${path.module}/../../src/site/Dockerfile")
    html_hash       = filemd5("${path.module}/../../src/site/index.html.tpl")
  }

  provisioner "local-exec" {
    command = <<-EOT
      gcloud builds submit ${path.module}/../../src/site --tag=${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.frontend-repo.name}/frontend:latest --project=${var.project}
    EOT
  }

  depends_on = [google_artifact_registry_repository.frontend-repo, local_file.frontend_html]
}


# Cloud run service to host the frontend nginx service
resource "google_artifact_registry_repository" "frontend-repo" {
  location      = var.region
  repository_id = "frontend-repo-${var.environment}"
  description   = "Docker repo for frontend service"
  format        = "DOCKER"
}


resource "google_cloud_run_v2_service" "frontend" {
  name                = "frontend-${var.environment}"
  location            = var.region
  project             = var.project
  deletion_protection = false

  template {
    service_account = var.service_account_email
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.frontend-repo.name}/frontend:latest"

      ports {
        container_port = 8080
      }

      env {
        name  = "CLOUD_FUNCTION_URL"
        value = google_cloudfunctions2_function.cloud_function.url
      }

      resources {
        limits = {
          cpu    = "1"
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
      egress    = "PRIVATE_RANGES_ONLY"
    }
  }
  ingress    = "INGRESS_TRAFFIC_ALL"
  depends_on = [null_resource.build_frontend_image, local_file.frontend_html]
}

resource "google_cloud_run_v2_service_iam_member" "public_access" {
  project  = var.project
  location = var.region
  name     = google_cloud_run_v2_service.frontend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# use templatefile to build the tpl file with the cloud function url
resource "local_file" "frontend_html" {
  content = templatefile("${path.module}/../../src/site/index.html.tpl", {
    CLOUD_FUNCTION_URL = google_cloudfunctions2_function.cloud_function.url
  })

  filename = "${path.module}/../../src/site/index.html"

  depends_on = [google_cloudfunctions2_function.cloud_function]
}
