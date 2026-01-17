# VPC Network
resource "google_compute_network" "vpc_network" {
  name                    = "${var.project}-vpc-${var.environment}"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# serverless subnet
resource "google_compute_subnetwork" "serverless-subnet" {
  name          = "${var.project}-serverless-${var.environment}"
  ip_cidr_range = var.main_subnet_cidr
  region        = var.region
  project       = var.project
  network       = google_compute_network.vpc_network.id
}

# Serverless VPC Access Connector
# This allows Cloud Functions and Cloud Run to access VPC resources
# VPC Access Connector for Serverless (Cloud Functions/Cloud Run)
resource "google_vpc_access_connector" "serverless-connector" {
  name          = "serverless-connector-${var.environment}"
  region        = var.region
  ip_cidr_range = var.connector_cidr
  network       = google_compute_network.vpc_network.name
  max_instances = 3
  min_instances = 2
  #   CHECK
  depends_on = [google_compute_subnetwork.serverless-subnet]
}

# allow cloud function through firewall
resource "google_compute_firewall" "allow_serverless" {
  name    = "${var.project}-allow-serverless-${var.environment}"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["serverless"]
}

# deny inbound rules
resource "google_compute_firewall" "deny_all" {
  name    = "${var.project}-deny-all-${var.environment}"
  network = google_compute_network.vpc_network.name

  deny {
    protocol = "all"
  }

  priority      = 65534
  source_ranges = ["0.0.0.0/0"]
}

# allow health checks into the firewall from google ip addresses
resource "google_compute_firewall" "allow_health_checks" {
  name    = "${var.project}-allow-google-health-checks"
  network = google_compute_network.vpc_network.name
  project = var.project

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}


# modules/storage/main.tf

resource "google_storage_bucket" "terraform_state" {
  name          = "${var.project}-terraform-stat-${var.project}"
  location      = var.region
  project       = var.project
  force_destroy = false

  uniform_bucket_level_access = true

  versioning {
    enabled = true # CRITICAL: Enable versioning for state recovery
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions         = 3 # Keep last 3 versions
      days_since_noncurrent_time = 30
    }
  }

  labels = {
    purpose     = "terraform-state"
    environment = var.environment
  }
}