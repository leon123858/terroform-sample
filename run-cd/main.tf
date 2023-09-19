module "global_var" {
  source = "./global_setting"
}

provider "google" {
  project = module.global_var.project_id
  region  = module.global_var.region
}

module "sql-instance" {
  source       = "./instances"
  service_name = module.global_var.service-name
  region       = module.global_var.region
  run-sa       = "77786086397-compute@developer.gserviceaccount.com"
  db-name      = "postgres"
}

module "cicd" {
  source     = "./cicd"
  depends_on = [module.sql-instance]

  git_token = "<your git token>"
  build_sa = "service-77786086397@gcp-sa-cloudbuild.iam.gserviceaccount.com"
  git_app_id = "36856157"
  builder_sa = "77786086397@cloudbuild.gserviceaccount.com"
  service_name = module.global_var.service-name
}
