resource "google_cloudfunctions_function" "cloud_function" {
  name        = var.function_name
  runtime     = "python39"
  trigger_http = true
  entry_point = "hello_world"
  
  source_archive_bucket = var.source_bucket
  source_archive_object = var.source_object

  environment_variables = {
    ENV = "production"
  }
}