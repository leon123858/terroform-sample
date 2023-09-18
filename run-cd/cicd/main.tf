module "global_var" {
  source = "../global_setting"
}

module "git-connection" {
  source     = "./github-connection"
  secret_id  = "github-token"
  name       = "github-connection"
  git_token  = var.git_token
  git_app_id = var.git_app_id
  build_sa   = var.build_sa
  region     = module.global_var.region
}

module "builder" {
  source        = "./cloud-build"
  name          = "manual-trigger-test"
  git-url       = module.global_var.git-url
  file          = module.global_var.build-file-path
  region        = module.global_var.region
  connection-id = module.git-connection.id

  depends_on = [module.git-connection]
}
