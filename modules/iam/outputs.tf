# IAM Module Outputs


output "cloudrun_service_account_email" {
    value = google_service_account.cloud_run_sa.email
}

output "cloud_function_account_email" {
    value = google_service_account.cloud_function_sa.email
}

output "cloud_function_servce_acount_name" {
    value = google_service_account.cloud_function_sa.name
}

output cloudrun_service_account_name {
    value = google_service_account.cloud_run_sa.name
}