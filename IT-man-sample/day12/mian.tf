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

resource "google_firestore_database" "database" {
  name = "test-db-1"

  location_id = var.region
  type        = "FIRESTORE_NATIVE"

  depends_on = [null_resource.delay]
}
