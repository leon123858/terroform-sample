// Create a secret containing the personal access token and grant permissions to the Service Agent
resource "google_secret_manager_secret" "github_token_secret" {
  secret_id = var.secret_id

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "github_token_secret_version" {
  secret      = google_secret_manager_secret.github_token_secret.id
  secret_data = var.git_token

  depends_on = [google_secret_manager_secret.github_token_secret]
}

resource "google_secret_manager_secret_iam_member" "policy" {
  secret_id = var.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.build_sa}"

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
  name     = var.name

  github_config {
    app_installation_id = var.git_app_id
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github_token_secret_version.id
    }
  }
  depends_on = [null_resource.delay]
}

resource "google_cloudbuildv2_repository" "my-repository" {
  name              = "${var.name}-repo"
  location          = var.region
  parent_connection = google_cloudbuildv2_connection.my_connection.id
  remote_uri        = "${var.git-url}.git"

  depends_on = [google_cloudbuildv2_connection.my_connection]
}
