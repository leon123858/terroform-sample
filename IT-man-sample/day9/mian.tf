provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_service_account" "backup_service" {
  account_id   = "service-account-backup"
  display_name = "backup"
  description  = "Service Account For Backup"
}
