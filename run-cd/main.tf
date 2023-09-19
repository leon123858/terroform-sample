module "global_var" {
  source = "./global_setting"
}

provider "google" {
  project = module.global_var.project_id
  region  = module.global_var.region
}

module "sql-instance" {
  source       = "./instances"
  service_name = "docker-sample"
  region       = module.global_var.region
  run-sa       = "77786086397-compute@developer.gserviceaccount.com"
  db-name      = "postgres"
}

module "cicd" {
  source     = "./cicd"
  depends_on = [module.sql-instance]
}
