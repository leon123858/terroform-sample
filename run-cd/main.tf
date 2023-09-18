module "global_var" {
  source = "./global_setting"
}

provider "google" {
  project = module.global_var.project_id
  region  = module.global_var.region
}

module "cicd" {
  source     = "./cicd"
  git_app_id = "36856157"
  git_token  = "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"
  build_sa   = "service-77786086397@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}
