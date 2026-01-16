# Storage Module Outputs

output "firestore_database_id" {
  description = "Firestore database ID"
  value       = google_firestore_database.default.name
}

output "static_content_bucket" {
  description = "Static website content bucket name"
  value       = google_storage_bucket.static_content.name
}

output "static_content_bucket_url" {
  description = "Static website bucket URL"
  value       = "gs://${google_storage_bucket.static_content.name}"
}

output "terraform_state_bucket" {
  description = "Terraform remote state bucket name"
  value       = google_storage_bucket.terraform_state.name
}

output "terraform_state_bucket_url" {
  description = "Terraform state bucket URL"
  value       = "gs://${google_storage_bucket.terraform_state.name}"
}
