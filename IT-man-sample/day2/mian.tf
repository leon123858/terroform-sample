provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_disk" "default" {
  name = "datadisk"
  type = "pd-ssd"
  zone = var.zone
  size = 200

  physical_block_size_bytes = 4096
}

resource "google_compute_instance" "instance-1" {
  depends_on = [google_compute_disk.default]

  attached_disk {
    source = google_compute_disk.default.self_link
    mode   = "READ_WRITE"
  }

  boot_disk {
    auto_delete = true
    device_name = "instance-1"

    initialize_params {
      image = "projects/debian-cloud/global/images/debian-11-bullseye-v20230814"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = "e2-micro"
  name         = "instance-1"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    subnetwork = "projects/tw-rd-ca-leon-lin/regions/asia-east1/subnetworks/default"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = "77786086397-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  tags = ["http-server", "https-server"]
  zone = var.zone
}
