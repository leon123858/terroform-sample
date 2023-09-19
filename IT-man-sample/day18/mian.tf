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
  secret_data = "YOUR-GIT-TOKEN"

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