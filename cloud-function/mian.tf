provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "bucket" {
  name                        = "${var.project_id}-gcf-source" # Every bucket name must be globally unique
  location                    = "ASIA"
  uniform_bucket_level_access = true

  force_destroy = true
}

resource "google_storage_bucket_object" "object" {
  name   = "cloudFunc.zip"
  bucket = google_storage_bucket.bucket.name
  source = "./cloudFunc.zip" # Add path to the zipped function source code

  depends_on = [ google_storage_bucket.bucket ]
}

resource "google_cloudfunctions2_function" "function" {
  name        = "my-function-v2"
  location    = var.region
  description = "a new function"

  build_config {
    runtime     = "go120"
    entry_point = "HelloGet" # Set the entry point 
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
    ingress_settings   = "ALLOW_ALL"
  }

  depends_on = [ google_storage_bucket_object.object ]
}

resource "google_cloud_run_service_iam_member" "member" {
  location = google_cloudfunctions2_function.function.location
  project = google_cloudfunctions2_function.function.project
  service = google_cloudfunctions2_function.function.name
  role = "roles/run.invoker"
  member = "allUsers"

  depends_on = [ google_cloudfunctions2_function.function ]
}
