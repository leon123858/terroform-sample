provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "static" {
 name          = "unique-name-leon-lin-bucket-${var.project_id}"
 location      = "ASIA"
 storage_class = "STANDARD"

 uniform_bucket_level_access = true
}

# Upload a text file as an object
# to the storage bucket

resource "google_storage_bucket_object" "default" {
 name         = "test"
 source       = "./test.txt"
 content_type = "text/plain"
 bucket       = google_storage_bucket.static.id
}