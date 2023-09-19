module "global_var" {
  source = "./global_setting"
}

provider "google" {
  project = module.global_var.project_id
  region  = module.global_var.region
}

module "cicd" {
  source = "./cicd"
}
