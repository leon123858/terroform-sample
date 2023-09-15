provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  db_name = "(default)"
}

# resource "google_firestore_database" "database" {
#   name = local.db_name

#   location_id = var.region
#   type        = "FIRESTORE_NATIVE"
# }

module "gcs" {
  source     = "./gcs"
  project_id = var.project_id
  location   = var.location
}

module "account" {
  source     = "./account"
  project_id = var.project_id
}

# 設置 IAM 後多等一下, 避免 bug
resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 60"
  }
  depends_on = [module.account]
}

module "workflow" {
  source     = "./workflow"
  project_id = var.project_id
  region     = var.region
  file       = "./flow"
  account    = module.account.self_link

  # depends_on = [google_firestore_database.database, module.gcs, module.account]
  depends_on = [module.gcs, null_resource.delay]
}

module "scheduler" {
  source     = "./scheduler"
  project_id = var.project_id
  email      = module.account.mail
  region     = var.region
  name       = module.workflow.name
  bucket     = module.gcs.path
  db         = local.db_name

  depends_on = [module.workflow]
}



