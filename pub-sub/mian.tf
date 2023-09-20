provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  storage_sa = "service-77786086397@gs-project-accounts.iam.gserviceaccount.com" # can get in gcs cloud console setting GUI
}

# 發布 cloud function 且用 pubsub 觸發
resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_service_account" "default" {
  account_id   = "test-gcf-sa"
  display_name = "Test Service Account"
}

resource "google_pubsub_topic" "default" {
  name = "functions2-topic"
}

resource "google_storage_bucket" "default" {
  name                        = "${random_id.bucket_prefix.hex}-gcf-source" # Every bucket name must be globally unique
  location                    = "ASIA"
  uniform_bucket_level_access = true

  force_destroy = true
}

resource "google_storage_bucket_object" "default" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.default.name
  source = "./cloudFunc.zip"
}

resource "google_cloudfunctions2_function" "default" {
  name        = "my-function"
  location    = var.region
  description = "a new function"

  build_config {
    runtime     = "go119"
    entry_point = "HelloPubSub" # Set the entry point
    environment_variables = {
      BUILD_CONFIG_TEST = "build_test"
    }
    source {
      storage_source {
        bucket = google_storage_bucket.default.name
        object = google_storage_bucket_object.default.name
      }
    }
  }

  service_config {
    max_instance_count = 3
    min_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
    environment_variables = {
      SERVICE_CONFIG_TEST = "config_test"
    }
    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.default.email
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.default.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }
}

# 允許發布通知
resource "google_pubsub_topic_iam_member" "member" {
  topic   = google_pubsub_topic.default.id
  role    = "roles/pubsub.publisher"
  member = "serviceAccount:${local.storage_sa}"
}

# GCS 發布通知
resource "google_storage_notification" "notification" {
  bucket         = google_storage_bucket.default.name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.default.id
  event_types    = ["OBJECT_FINALIZE", "OBJECT_METADATA_UPDATE"]
  custom_attributes = {
    new-attribute = "new-attribute-value"
  }
  depends_on = [google_pubsub_topic_iam_member.member]
}