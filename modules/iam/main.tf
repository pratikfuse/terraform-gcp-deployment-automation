
# IAM Module - Service Accounts and IAM Bindings

resource "google_service_account" "cloud_function_sa" {
  account_id   = "${var.project}-fn-sa-${var.environment}"
  display_name = "Cloud Function Service Account"
  project      = var.project
  description  = "Service account for Cloud function"
}

resource "google_service_account" "cloud_run_sa" {
  account_id   = "${var.project}-run-sa-${var.environment}"
  display_name = "Cloud Run Service Account"
  project      = var.project
  description  = "Service account for Cloud Run"
}

resource "google_project_iam_member" "function_firestore_user" {
  project    = var.project
  role       = "roles/datastore.user"
  member     = "serviceAccount:${google_service_account.cloud_function_sa.email}"
  depends_on = [google_service_account.cloud_function_sa]
}


# cloud function sa to allow logs
resource "google_project_iam_member" "function_log_writer" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_function_sa.email}"
}


# cloud run sa to allow write logs
resource "google_project_iam_member" "cloud_run_log_writer" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Optional: If Cloud Run needs to call Cloud Function
resource "google_project_iam_member" "cloud_run_function_invoker" {
  project = var.project
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}