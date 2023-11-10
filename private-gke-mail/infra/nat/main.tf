resource "google_compute_router" "router" {
  project = var.project_id
  name    = "${var.name}-router"
  network = var.network
  region  = var.region
}

module "cloud-nat" {
  source                             = "terraform-google-modules/cloud-nat/google"
  project_id                         = var.project_id
  region                             = var.region
  router                             = google_compute_router.router.name
  name                               = "${var.name}-config"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
