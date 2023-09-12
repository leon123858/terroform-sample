provider "google" {
  project = var.project_id
  region  = var.region
}

# Create the securenetwork network
resource "google_compute_network" "securenetwork" {
  name                    = "securenetwork"
  auto_create_subnetworks = "false"
}
# Add a subnet to securenetwork
# Add subnet to the VPC network.
# Create subnet subnetwork
resource "google_compute_subnetwork" "securenetwork" {
  depends_on    = [google_compute_subnetwork.securenetwork]
  name          = "securenetwork"
  region        = var.region
  network       = google_compute_network.securenetwork.self_link
  ip_cidr_range = "10.130.0.0/20"
}
# Configure the firewall rule
# Define a firewall rule to allow HTTP, SSH, and RDP traffic on securenetwork.
# 外部任意區允許進入堡壘機
resource "google_compute_firewall" "bastionbost-allow-ssh" {
  depends_on    = [google_compute_network.securenetwork]
  name          = "bastionbost-allow-ssh"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bastion"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
# 堡壘機可以自由 acccess 內網
resource "google_compute_firewall" "securenetwork-allow-ssh" {
  depends_on    = [google_compute_network.securenetwork]
  name          = "securenetwork-allow-rdp"
  network       = google_compute_network.securenetwork.self_link
  source_ranges = ["10.130.0.0/20"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# 安全機
resource "google_compute_instance" "safe_instance" {
  depends_on   = [google_compute_network.securenetwork]
  name         = "secure"
  zone         = var.zone
  machine_type = "e2-medium"
  tags         = ["secure"]

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/debian-11-bullseye-v20230814"
      size  = 20
      type  = "pd-balanced"
    }
  }
  network_interface {
    subnetwork = google_compute_network.securenetwork.self_link
    access_config {
      # Allocate a one-to-one NAT IP to the instance
    }
  }
}

# 堡壘機
resource "google_compute_instance" "bastion_instance" {
  depends_on   = [google_compute_network.securenetwork]
  name         = "bastion"
  zone         = var.zone
  machine_type = "e2-medium"
  tags         = ["bastion"]
  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/debian-11-bullseye-v20230814"
      size  = 20
      type  = "pd-balanced"
    }
  }
  network_interface {
    subnetwork = google_compute_network.securenetwork.self_link
    access_config {
      # Allocate a one-to-one NAT IP to the instance
    }
  }
}
