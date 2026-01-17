
output "firestore_database_id" {
  description = "Firestore database ID"
  value       = google_firestore_database.default.id
}

output "terraform_state_bucket" {
  description = "Terraform remote state bucket name"
  value       = google_storage_bucket.terraform_state.name
}

output "terraform_state_bucket_url" {
  description = "Terraform state bucket URL"
  value       = "gs://${google_storage_bucket.terraform_state.name}"
}


output "function_code_bucket" {
  description = "Cloud Function code bucket name"
  value       = google_storage_bucket.function_code.name
}

output "function_code_bucket_url" {
  description = "Cloud Function code bucket URL"
  value       = "gs://${google_storage_bucket.function_code.name}"
}

output "firestore_database_name" {
  description = "Firebase database name"
  value       = google_firestore_database.default.name
}