resource "google_storage_bucket" "firestore-backup-bucket" {
  name          = "firestore-backup-bucket-${var.project_id}"
  location      = var.location
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type = "Delete"
    }
  }

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}
