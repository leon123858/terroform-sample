resource "google_cloud_scheduler_job" "job" {
  name             = "firestore-backup"
  description      = "http backup by workflow"
  schedule         = "59 23 * * *"
  time_zone        = "Asia/Taipei"
  attempt_deadline = "320s"

  http_target {
    http_method = "POST"
    uri         = "https://workflowexecutions.googleapis.com/v1/projects/${var.project_id}/locations/${var.region}/workflows/${var.name}/executions"
    body        = base64encode(jsonencode({"argument":"{\n    \"db\": \"${var.db}\",\n    \"path\" : \"${var.bucket}\"\n}","callLogLevel":"CALL_LOG_LEVEL_UNSPECIFIED"}))
    oauth_token {
      service_account_email = var.email
    }
  }
}

