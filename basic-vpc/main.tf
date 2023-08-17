# We require a project to be provided upfront
# Create a project at https://cloud.google.com/
# Make note of the project ID
# We need a storage bucket created upfront too to store the terraform state
terraform {}

# You need to fill these locals out with the project, region and zone
# Then to boot it up, run:-
#   gcloud auth application-default login
#   terraform init
#   terraform apply
locals {
  # The Google Cloud Project ID that will host and pay for your Minecraft server
  project = "qwiklabs-gcp-02-706aa7b92be3"
  region  = "us-east1"
  zone    = "us-east1-b"
}


provider "google" {
  project = local.project
  region  = local.region
}

module "dev-vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 7.0"
  project_id   = local.project # Replace this with your project ID in quotes
  network_name = "griffin-dev-vpc"
  mtu          = 1460

  subnets = [
    {
      subnet_name   = "griffin-dev-wp"
      subnet_ip     = "192.168.16.0/20"
      subnet_region = local.region
    },
    {
      subnet_name           = "griffin-dev-mgmt"
      subnet_ip             = "192.168.32.0/20"
      subnet_region         = local.region
    },
  ]
}

module "prod-vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 7.0"
  project_id   = local.project # Replace this with your project ID in quotes
  network_name = "griffin-prod-vpc"
  mtu          = 1460

  subnets = [
    {
      subnet_name   = "griffin-prod-wp"
      subnet_ip     = "192.168.16.0/20"
      subnet_region = local.region
    },
    {
      subnet_name           = "griffin-prod-mgmt"
      subnet_ip             = "192.168.64.0/20"
      subnet_region         = local.region
    },
  ]
}

resource "google_compute_firewall" "dev-rules" {
  name        = "dev-rules"
  network     = "griffin-dev-vpc"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "prod-rules" {
  name        = "prod-rules"
  network     = "griffin-prod-vpc"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "bastion" {
  name         = "bastion"
  machine_type = "e2-medium"
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/debian-11-bullseye-v20230814"
      size  = 10
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = "projects/${local.project}/regions/${local.region}/subnetworks/griffin-prod-mgmt"
    access_config {
      network_tier = "PREMIUM"
    }
  }
  network_interface {
    subnetwork = "projects/${local.project}/regions/${local.region}/subnetworks/griffin-dev-mgmt"
    access_config {
      network_tier = "PREMIUM"
    }
  }
}

resource "google_sql_database_instance" "griffin-dev-db" {
  name             = "griffin-dev-db"
  region           = local.region
  database_version = "MYSQL_8_0"
  root_password    = "abcABC123!"
  settings {
    tier = "db-f1-micro"
    password_validation_policy {
      min_length                  = 6
      complexity                  = "COMPLEXITY_DEFAULT"
      reuse_interval              = 2
      disallow_username_substring = true
      enable_password_policy      = true
    }
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}
