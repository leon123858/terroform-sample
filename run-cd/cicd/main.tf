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
  git-url    = module.global_var.git-url
}

resource "google_artifact_registry_repository" "docker-images" {
  location      = module.global_var.region
  repository_id = "docker-sample"
  description   = "example docker repository"
  format        = "DOCKER"

  docker_config {
    immutable_tags = true
  }
}

module "build" {
  source    = "./cloud-build"
  name      = "docker-sample"
  file      = module.global_var.build-file-path
  region    = module.global_var.region
  repo-id   = module.git-connection.repo-id
  repo-name = google_artifact_registry_repository.docker-images.name

  depends_on = [module.git-connection, google_artifact_registry_repository.docker-images]
}
