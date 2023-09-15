provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_firestore_database" "database" {
  name = "test-db-3"

  location_id = var.region
  type        = "FIRESTORE_NATIVE"
}

module "gcs" {
  source     = "./gcs"
  project_id = var.project_id
  location   = var.location
}

module "account" {
  source     = "./account"
  project_id = var.project_id
}

module "workflow" {
  source     = "./workflow"
  project_id = var.project_id
  region     = var.region
  file       = "./flow"
  account    = module.account.self_link

  depends_on = [google_firestore_database.database, module.gcs, module.account]
}

module "scheduler" {
  source     = "./scheduler"
  project_id = var.project_id
  email      = module.account.mail
  region     = var.region
  name       = module.workflow.name
  bucket     = module.gcs.path
  db         = google_firestore_database.database.name

  depends_on = [module.workflow]
}



