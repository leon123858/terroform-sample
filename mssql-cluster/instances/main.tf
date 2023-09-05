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

resource "google_compute_disk" "data-disk1" {
  name = "${var.vm_db1_name}-datadisk"
  type = "pd-ssd"
  zone = var.vm_zone1_name
  size = 200

  physical_block_size_bytes = 4096
}

resource "google_compute_disk" "data-disk2" {
  name = "${var.vm_db2_name}-datadisk"
  type = "pd-ssd"
  zone = var.vm_zone2_name
  size = 200

  physical_block_size_bytes = 4096
}

resource "google_compute_instance" "db1" {
  depends_on = [google_compute_disk.data-disk1]

  attached_disk {
    source = google_compute_disk.data-disk1.self_link
    mode   = "READ_WRITE"
  }

  metadata = {
    enable-wsfc                   = "true"
    sysprep-specialize-script-ps1 = "$ErrorActionPreference = \"stop\"\n\n# Install required Windows features\nInstall-WindowsFeature Failover-Clustering -IncludeManagementTools\nInstall-WindowsFeature RSAT-AD-PowerShell\n\n# Open firewall for WSFC\nnetsh advfirewall firewall add rule name=\"Allow SQL Server health check\" dir=in action=allow protocol=TCP localport=59997\n\n# Open firewall for SQL Server\nnetsh advfirewall firewall add rule name=\"Allow SQL Server\" dir=in action=allow protocol=TCP localport=1433\n\n# Open firewall for SQL Server replication\nnetsh advfirewall firewall add rule name=\"Allow SQL Server replication\" dir=in action=allow protocol=TCP localport=5022\n\n# Format data disk\nGet-Disk |\n Where partitionstyle -eq 'RAW' |\n Initialize-Disk -PartitionStyle MBR -PassThru |\n New-Partition -AssignDriveLetter -UseMaximumSize |\n Format-Volume -FileSystem NTFS -NewFileSystemLabel 'Data' -Confirm:$false\n\n# Create data and log folders for SQL Server\nmd d:\\Data\nmd d:\\Logs"
  }

  boot_disk {
    auto_delete = true
    device_name = var.vm_db1_name

    initialize_params {
      image = "projects/windows-sql-cloud/global/images/sql-2014-enterprise-windows-2012-r2-dc-v20230809"
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

  machine_type = "n1-standard-1"
  name         = var.vm_db1_name

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    network_ip = "10.10.20.2"
    subnetwork = "projects/${var.project_id}/regions/${var.region}/subnetworks/${var.sql_subnet_name}"
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

  tags = ["ad-member", "rdp", "sql", "wsfc", "wsfc-node"]
  zone = var.vm_zone1_name
}

resource "google_compute_instance" "db2" {
  depends_on = [google_compute_disk.data-disk2]

  attached_disk {
    source = google_compute_disk.data-disk2.self_link
    mode   = "READ_WRITE"
  }

  metadata = {
    enable-wsfc                   = "true"
    sysprep-specialize-script-ps1 = "$ErrorActionPreference = \"stop\"\n\n# Install required Windows features\nInstall-WindowsFeature Failover-Clustering -IncludeManagementTools\nInstall-WindowsFeature RSAT-AD-PowerShell\n\n# Open firewall for WSFC\nnetsh advfirewall firewall add rule name=\"Allow SQL Server health check\" dir=in action=allow protocol=TCP localport=59997\n\n# Open firewall for SQL Server\nnetsh advfirewall firewall add rule name=\"Allow SQL Server\" dir=in action=allow protocol=TCP localport=1433\n\n# Open firewall for SQL Server replication\nnetsh advfirewall firewall add rule name=\"Allow SQL Server replication\" dir=in action=allow protocol=TCP localport=5022\n\n# Format data disk\nGet-Disk |\n Where partitionstyle -eq 'RAW' |\n Initialize-Disk -PartitionStyle MBR -PassThru |\n New-Partition -AssignDriveLetter -UseMaximumSize |\n Format-Volume -FileSystem NTFS -NewFileSystemLabel 'Data' -Confirm:$false\n\n# Create data and log folders for SQL Server\nmd d:\\Data\nmd d:\\Logs"
  }

  boot_disk {
    auto_delete = true
    device_name = var.vm_db2_name

    initialize_params {
      image = "projects/windows-sql-cloud/global/images/sql-2014-enterprise-windows-2012-r2-dc-v20230809"
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

  machine_type = "n1-standard-1"
  name         = var.vm_db2_name

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    network_ip = "10.10.20.3"
    subnetwork = "projects/${var.project_id}/regions/${var.region}/subnetworks/${var.sql_subnet_name}"
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

  tags = ["ad-member", "rdp", "sql", "wsfc", "wsfc-node"]
  zone = var.vm_zone2_name
}

resource "google_compute_instance" "fsw1" {
  boot_disk {
    auto_delete = true
    device_name = var.vm_fsw1

    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2019-dc-v20230809"
      size  = 50
      type  = "pd-ssd"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = "n1-standard-1"

  metadata = {
    sysprep-specialize-script-ps1 = "add-windowsfeature FS-FileServer"
  }

  name = var.vm_fsw1

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    network_ip = "10.10.20.4"
    subnetwork = "projects/${var.project_id}/regions/${var.region}/subnetworks/${var.sql_subnet_name}"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  tags = ["ad-member", "fsw", "rdp", "wsfc"]
  zone = var.vm_zone3_name
}
