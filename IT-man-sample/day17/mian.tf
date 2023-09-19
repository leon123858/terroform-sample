provider "google" {
  project = var.project_id
  region  = var.region
}

// Create a secret containing the personal access token and grant permissions to the Service Agent
resource "google_secret_manager_secret" "token_secret" {
  secret_id = "secret-id"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "github_token_secret_version" {
  secret      = google_secret_manager_secret.token_secret.id
  secret_data = "test-secret-data"

  depends_on = [ google_secret_manager_secret.token_secret ]
}
# 賦予帳戶 access secret 的權利
resource "google_secret_manager_secret_iam_member" "policy" {
  secret_id = "secret-id"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${"77786086397@cloudbuild.gserviceaccount.com"}"

  depends_on = [google_secret_manager_secret_version.github_token_secret_version]
}