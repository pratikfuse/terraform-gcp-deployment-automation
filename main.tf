terraform {

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

# apis to be enabled for the project
locals {
  required_apis = [
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "firestore.googleapis.com",
    "vpcaccess.googleapis.com",
    "compute.googleapis.com"
  ]
}

resource "google_project_service" "required_apis" {
  for_each = toset(local.required_apis)

  project            = var.project
  service            = each.value
  disable_on_destroy = false
}

provider "google" {
  project = var.project
  region  = var.region
}

# Networking Module
module "networking" {
  source      = "./modules/networking"
  project     = var.project
  region      = var.region
  depends_on  = [local.required_apis]
  environment = var.environment
}

# IAM Module
module "iam" {
  source      = "./modules/iam"
  project     = var.project
  depends_on  = [local.required_apis]
  environment = var.environment
}

# Storage Module
module "storage" {
  source             = "./modules/storage"
  project            = var.project
  region             = var.region
  environment        = var.environment
  depends_on         = [local.required_apis]
  firestore_location = var.region

}

# Compute Module
module "compute" {
  source                               = "./modules/compute"
  project                              = var.project
  region                               = var.region
  environment                          = var.environment
  zone                                 = var.zone
  function_code_bucket                 = module.storage.function_code_bucket
  vpc_connector_id                     = module.networking.serverless_connector_id
  firestore_database_name              = module.storage.firestore_database_name
  cloudrun_service_account_email       = module.iam.cloudrun_service_account_email
  cloud_function_service_account_email = module.iam.cloud_function_service_account_email
  depends_on = [
    module.networking,
    module.storage,
    module.iam
  ]
}
