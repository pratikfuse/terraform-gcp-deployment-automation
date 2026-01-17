# Compute Module Outputs


output "function_url" {
  description = "URL fo the deployed cloud function"
  value       = google_cloudfunctions2_function.cloud_function.url
}

output "cloudrun_url" {
  description = "URL of the Cloud Run service"
  value       = google_cloud_run_v2_service.frontend.uri
}

output "artifact_registry_repository" {
  description = "Artifact Registry repository name"
  value       = google_artifact_registry_repository.frontend-repo.name
}

output "frontend_url" {
  description = "Frontend Url"
  value       = google_cloud_run_v2_service.frontend.uri
}