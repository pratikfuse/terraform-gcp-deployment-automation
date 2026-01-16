terraform {

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  credentials = file("C:\\Users\\locsupp\\AppData\\Roaming\\gcloud\\application_default_credentials.json")
}

# Networking Module
# module "networking" {
#   source  = "./modules/networking"
#   project = var.project
#   region  = var.region
# }

# IAM Module
module "iam" {
  source = "./modules/iam"
  project = var.project
}

# Storage Module
module "storage" {
  source      = "./modules/storage"
  project     = var.project
  region      = var.region
  environment = var.environment
}

# Compute Module
module "compute" {
  source                = "./modules/compute"
  project               = var.project
  region                = var.region
  zone                  = var.zone
  function_code_bucket  = module.storage.function_code_bucket
}