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

resource "google_project_iam_member" "r1" {
  project    = var.project_id
  role       = "roles/datastore.importExportAdmin"
  member     = "serviceAccount:${google_service_account.backup_service.email}"
  depends_on = [null_resource.delay]
}

resource "google_project_iam_member" "r2" {
  project    = var.project_id
  role       = "roles/storage.objectCreator"
  member     = "serviceAccount:${google_service_account.backup_service.email}"
  depends_on = [null_resource.delay]
}

resource "google_project_iam_member" "r3" {
  project    = var.project_id
  role       = "roles/workflows.invoker"
  member     = "serviceAccount:${google_service_account.backup_service.email}"
  depends_on = [null_resource.delay]
}
