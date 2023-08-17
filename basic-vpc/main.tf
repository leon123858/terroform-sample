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

// gcloud compute --project=qwiklabs-gcp-02-706aa7b92be3 firewall-rules create dev-rules --direction=INGRESS --priority=1000 --network=griffin-dev-vpc --action=ALLOW --rules=tcp:22 --source-ranges=0.0.0.0/0
// gcloud compute --project=qwiklabs-gcp-02-706aa7b92be3 firewall-rules create dev-rules --direction=INGRESS --priority=1000 --network=griffin-prod-vpc --action=ALLOW --rules=tcp:22 --source-ranges=0.0.0.0/0

resource "google_compute_instance" "bastion" {
  boot_disk {
    auto_delete = true
    device_name = "bastion"

    initialize_params {
      image = "projects/debian-cloud/global/images/debian-11-bullseye-v20230814"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = "e2-medium"

  metadata = {
    enable-oslogin = "true"
  }

  name = "bastion"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    subnetwork = "projects/qwiklabs-gcp-02-706aa7b92be3/regions/us-east1/subnetworks/griffin-dev-mgmt"
  }

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    subnetwork = "projects/qwiklabs-gcp-02-706aa7b92be3/regions/us-east1/subnetworks/griffin-prod-mgmt"
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  zone = "us-east1-b"
}


resource "google_sql_database_instance" "griffin-dev-db" {
  name             = "griffin-dev-db"
  region           = local.region
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-f1-micro"
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}
