provider "google" {
  project = var.project_id
  region  = var.region
}

// source code repository
module "repository" {
  source     = "./repository"
  name       = "mail-server"
  region     = var.region
  git_url    = var.git_url
  git_app_id = var.git_app_id
  git_token  = var.git_token
}

// cloud build set
data "google_project" "project" {
}

locals {
  cloud_build_sa = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "build_r0" {
  project = var.project_id
  role    = "roles/run.admin"
  # service accout in prject named "Cloud Build Service Account"
  member = local.cloud_build_sa
}

resource "google_project_iam_member" "build_r1" {
  project = var.project_id
  role    = "roles/cloudfunctions.developer"
  # service accout in prject named "Cloud Build Service Account"
  member = local.cloud_build_sa

  depends_on = [google_project_iam_member.build_r0]
}

resource "google_project_iam_member" "build_r2" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  # service accout in prject named "Cloud Build Service Account"
  member = local.cloud_build_sa

  depends_on = [google_project_iam_member.build_r1]
}

// cloud build image
module "mail_server" {
  source           = "./build_image"
  name             = "mail-server"
  region           = var.region
  docker_file_path = var.image_path
  source_repo      = module.repository.id
  depends_on       = [google_project_iam_member.build_r2]
}

// create gke in network
module "gke" {
  source       = "./gke"
  project_id   = var.project_id
  region       = var.region
  gke_location = "${var.region}-a"
}

// create cloud nat for gke
module "cloud_nat" {
  source     = "./nat"
  project_id = var.project_id
  region     = var.region
  network    = module.gke.vpc_name
  name       = "nat-gke"

  depends_on = [module.gke]
}

// create jump server
module "jump" {
  source         = "./jump_gce"
  name           = "jump"
  zone           = "${var.region}-a"
  subnetwork     = module.gke.gke_subnetwork_name
  project_number = data.google_project.project.number

  depends_on = [module.gke]
}
