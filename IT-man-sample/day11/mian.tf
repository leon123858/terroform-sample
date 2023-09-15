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

resource "google_workflows_workflow" "workflows_example" {
  name            = "sample-workflow"
  region          = var.region
  description     = "A sample workflow"
  service_account = google_service_account.backup_service.id
  source_contents = file("./flow.yaml")

  depends_on = [null_resource.delay]
}
