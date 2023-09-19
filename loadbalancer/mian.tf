provider "google" {
  project = var.project_id
  region  = var.region
}

# Create Cloud Storage buckets
resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "bucket_1" {
  name                        = "${random_id.bucket_prefix.hex}-bucket-1"
  location                    = var.region
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  // delete bucket and contents on destroy.
  force_destroy = true
}

resource "google_storage_bucket" "bucket_2" {
  name                        = "${random_id.bucket_prefix.hex}-bucket-2"
  location                    = var.region
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  // delete bucket and contents on destroy.
  force_destroy = true
}

# Make buckets public
resource "google_storage_bucket_iam_member" "bucket_1" {
  bucket = google_storage_bucket.bucket_1.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"

  depends_on = [ google_storage_bucket.bucket_1 ]
}

resource "google_storage_bucket_iam_member" "bucket_2" {
  bucket = google_storage_bucket.bucket_2.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"

  depends_on = [ google_storage_bucket.bucket_2 ]
}

# Reserve IP address
resource "google_compute_global_address" "default" {
  name = "example-ip"
}

# Create LB backend buckets
resource "google_compute_backend_bucket" "bucket_1" {
  name        = "cats"
  description = "Contains cat image"
  bucket_name = google_storage_bucket.bucket_1.name
}

resource "google_compute_backend_bucket" "bucket_2" {
  name        = "dogs"
  description = "Contains dog image"
  bucket_name = google_storage_bucket.bucket_2.name
}

# Create url map
resource "google_compute_url_map" "default" {
  name = "http-lb"

  default_service = google_compute_backend_bucket.bucket_1.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "path-matcher"
  }

  path_matcher {
    name            = "path-matcher"
    default_service = google_compute_backend_bucket.bucket_1.id
    path_rule {
       paths   = ["/two/*"]
       service = google_compute_backend_bucket.bucket_2.id
    }
    path_rule {
      paths   = ["/one/*"]
      service = google_compute_backend_bucket.bucket_1.id
    }
  }
}

# Create HTTP target proxy
resource "google_compute_target_http_proxy" "default" {
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.default.id

  depends_on = [ google_compute_url_map.default ]
}

# Create forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "http-lb-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.default.id

  depends_on = [ google_compute_target_http_proxy.default,google_compute_global_address.default ]
}


