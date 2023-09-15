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

resource "google_cloud_scheduler_job" "job" {
  name             = "test-job"
  description      = "test http job"
  schedule         = "59 23 * * *"
  time_zone        = "CST"
  attempt_deadline = "320s"

  http_target {
    http_method = "GET"
    uri         = "https://google.com.tw"
    /* body        = base64encode("{\"foo\":\"bar\"}") */
    oidc_token {
      service_account_email = google_service_account.backup_service.email
    }
  }
}
