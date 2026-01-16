# Compute Module Outputs


output "function_url" {
    description = "URL fo the deployed cloud function"
    value = google_cloudfunctions2_function.cloud_function.url
}