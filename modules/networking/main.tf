# Networking Module - VPC, Subnets, Firewall Rules, VPC Connector

# VPC Network
resource "google_compute_network" "vpc_network" {
  name                    = "${var.project}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Subnet for main workloads
resource "google_compute_subnetwork" "serverless-subnet" {
  name          = "${var.project}-serverless-subnet"
  ip_cidr_range = var.main_subnet_cidr
  region        = var.region
  project       = var.project
  network       = google_compute_network.vpc_network.id

  #   log_config {
  #     aggregation_interval = "INTERVAL_5_SEC"
  #   }
}

# Serverless VPC Access Connector
# This allows Cloud Functions and Cloud Run to access VPC resources
# This is the crucial step for connecting serverless services to vpc and define cidr range
# VPC Access Connector for Serverless (Cloud Functions/Cloud Run)
resource "google_vpc_access_connector" "serverless-connector" {
  name          = "serverless-connector"
  region        = var.region
  ip_cidr_range = var.connector_cidr
  network       = google_compute_network.vpc_network.name
  max_instances = 3
  min_instances = 2
  #   CHECK
  depends_on = [google_compute_subnetwork.serverless-subnet, google_project_service.vpnaccess_api]
}

# Enable VPN Access API
resource "google_project_service" "vpnaccess_api" {
  project            = var.project
  service            = "vpcaccess.googleapis.com"
  disable_on_destroy = false
}

# Firewall Rule: Allow internal communication (least-privilege)
resource "google_compute_firewall" "allow_internal" {
  # firewall name
  name    = "${var.project}-allow-internal"
  network = google_compute_network.vpc_network.name
  project = var.project

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  #   allow {
  #     protocol = "udp"
  #     ports    = ["0-65535"]
  #   }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.main_subnet_cidr]
  target_tags   = ["internal"]
}

# Firewall Rule: Allow Cloud Function
resource "google_compute_firewall" "allow_serverless" {
  name    = "${var.project}-allow-serverless"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["serverless"]
}

# Firewall Rule: Deny all other inbound (least-privilege default)
resource "google_compute_firewall" "deny_all" {
  name    = "${var.project}-deny-all"
  network = google_compute_network.vpc_network.name

  deny {
    protocol = "all"
  }

  priority      = 65534
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_health_checks" {
  name    = "${var.project}-allow-google-health-checks"
  network = google_compute_network.vpc_network.name
  project = var.project

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}
