module "vpc-module" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 7.0"
  project_id   = var.project_id
  network_name = var.custom_network
  mtu          = 1460

  subnets = [
    {
      subnet_name   = var.subnet_name
      subnet_ip     = var.subnet_ip
      subnet_region = var.region
    }
  ]
}

resource "google_container_cluster" "primary" {
  project             = var.project_id
  name                = var.gke_name
  location            = var.gke_location
  initial_node_count  = 2
  network             = module.vpc-module.network_name
  subnetwork          = module.vpc-module.subnets_names[0]
  deletion_protection = false

  private_cluster_config {
    master_ipv4_cidr_block  = "172.16.0.0/28"
    enable_private_endpoint = true
    enable_private_nodes    = true
  }
  ip_allocation_policy {
  }
  master_authorized_networks_config {
  }
}

resource "google_compute_firewall" "rules" {
  project = var.project_id
  name    = "gke-allow-ssh"
  network = module.vpc-module.network_name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}
