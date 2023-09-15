provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_service_account" "backup_service" {
  account_id   = "service-account-backup"
  display_name = "backup"
  description  = "Service Account For Backup"
}

resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 10"
  }
  depends_on = [google_service_account.backup_service]
}

resource "google_project_iam_member" "project" {
  project    = var.project_id
  role       = "roles/viewer"
  member     = "serviceAccount:${google_service_account.backup_service.email}"
  depends_on = [null_resource.delay]
}
