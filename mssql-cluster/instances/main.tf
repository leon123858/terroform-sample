resource "google_compute_instance" "ad1" {
  boot_disk {
    auto_delete = true
    device_name = var.vm_ad1_name

    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2019-dc-v20230809"
      size  = 50
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

  machine_type = "n1-standard-2"
  name         = var.vm_ad1_name

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    network_ip = "10.10.10.2"
    subnetwork = "projects/${var.project_id}/regions/${var.region}/subnetworks/${var.subnet_name}"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = true
    enable_vtpm                 = true
  }

  tags = ["ad", "rdp"]
  zone = var.vm_zone1_name
}

resource "google_compute_instance" "ad2" {
  boot_disk {
    auto_delete = true
    device_name = var.vm_ad2_name

    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2019-dc-v20230809"
      size  = 50
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

  machine_type = "n1-standard-2"
  name         = var.vm_ad2_name

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    network_ip = "10.10.10.3"
    subnetwork = "projects/${var.project_id}/regions/${var.region}/subnetworks/${var.subnet_name}"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = true
    enable_vtpm                 = true
  }

  tags = ["ad", "rdp"]
  zone = var.vm_zone2_name
}
