provider "google" {
  project = var.project_id
  region  = var.region
}

// Create a secret containing the personal access token and grant permissions to the Service Agent
resource "google_secret_manager_secret" "github_token_secret" {
  secret_id = "my-git-secret"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "github_token_secret_version" {
  secret      = google_secret_manager_secret.github_token_secret.id
  secret_data = "put your own git token"

  depends_on = [google_secret_manager_secret.github_token_secret]
}

resource "google_secret_manager_secret_iam_member" "policy" {
  secret_id = "my-git-secret"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${"service-77786086397@gcp-sa-cloudbuild.iam.gserviceaccount.com"}"

  depends_on = [google_secret_manager_secret_version.github_token_secret_version]
}

resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
  depends_on = [google_secret_manager_secret_iam_member.policy]
}

// Create the GitHub connection
resource "google_cloudbuildv2_connection" "my_connection" {
  location = var.region
  name     = "my-connection"

  github_config {
    app_installation_id = "36856157"
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github_token_secret_version.id
    }
  }
  depends_on = [null_resource.delay]
}

resource "google_cloudbuildv2_repository" "my-repository" {
  name              = "my-repo"
  location          = var.region
  parent_connection = google_cloudbuildv2_connection.my_connection.id
  remote_uri        = "${"https://github.com/leon123858/terroform-sample"}.git"

  depends_on = [google_cloudbuildv2_connection.my_connection]
}

resource "google_artifact_registry_repository" "docker-images" {
  location      = var.region
  repository_id = "docker-api"
  description   = "example docker repository"
  format        = "DOCKER"

  docker_config {
    immutable_tags = false
  }

  depends_on = [google_cloudbuildv2_repository.my-repository]
}

resource "google_cloudbuild_trigger" "manual-trigger" {
  location = var.region
  name     = "docker-api-triggrt"

  source_to_build {
    repository = google_cloudbuildv2_repository.my-repository.id
    ref        = "refs/heads/main"
    repo_type  = "GITHUB"
  }

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "--no-cache", "-t", "$_AR_HOSTNAME/$PROJECT_ID/$_REPO_NAME/$_SERVICE_NAME:$COMMIT_SHA", "${"docker-sample"}", "-f", "${"docker-sample/Dockerfile"}"]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "$_AR_HOSTNAME/$PROJECT_ID/$_REPO_NAME/$_SERVICE_NAME:$COMMIT_SHA"]
    }

    substitutions = {
      _SERVICE_NAME : "docker-sample"
      _DEPLOY_REGION : "${var.region}"
      _REPO_NAME : "docker-api"
      _AR_HOSTNAME : "${var.region}-docker.pkg.dev"
    }
  }


  // If this is set on a build, it will become pending when it is run, 
  // and will need to be explicitly approved to start.
  approval_config {
    approval_required = false
  }

  depends_on = [ google_artifact_registry_repository.docker-images ]
}