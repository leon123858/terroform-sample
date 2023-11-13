locals {
  gke_pod_range_name     = "gke-pods"
  gke_service_range_name = "gke-services"
}

resource "google_compute_network" "vpc-network" {
  name = var.custom_network
  mtu  = 1460
}
resource "google_compute_subnetwork" "vpc-subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_ip
  region        = var.region
  network       = google_compute_network.vpc-network.id
  secondary_ip_range = [
    {
      range_name    = local.gke_pod_range_name
      ip_cidr_range = "10.1.0.0/16"
    },
    {
      range_name    = local.gke_service_range_name
      ip_cidr_range = "10.2.0.0/16"
    }
  ]
}

resource "google_container_cluster" "primary" {
  project             = var.project_id
  name                = var.gke_name
  location            = var.gke_location
  initial_node_count  = 2
  network             = google_compute_network.vpc-network.name
  subnetwork          = google_compute_subnetwork.vpc-subnet.name
  deletion_protection = false

  private_cluster_config {
    master_ipv4_cidr_block  = "172.16.0.0/28"
    enable_private_endpoint = true
    enable_private_nodes    = true
  }
  ip_allocation_policy {
    cluster_secondary_range_name = local.gke_pod_range_name
    # cluster_ipv4_cidr_block       = "10.1.0.0/16"
    services_secondary_range_name = local.gke_service_range_name
    # services_ipv4_cidr_block      = "10.2.0.0/16"
  }
  master_authorized_networks_config {
  }

  depends_on = [google_compute_subnetwork.vpc-subnet]
}

resource "google_compute_firewall" "rules" {
  project = var.project_id
  name    = "gke-allow-ssh"
  network = google_compute_network.vpc-network.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}
