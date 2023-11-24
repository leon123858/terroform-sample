provider "google" {
}

locals {
  project_ids = [
    "cloudmile-service-project",
    # "prod-mgmt-service-project"
  ]
  number_of_projects = length(local.project_ids)
  region             = "asia-east1"
  zone               = "asia-east1-a"
  vm_service_account_scopes = [
    #
    #  Required by OS Config
    #
    "https://www.googleapis.com/auth/cloud-platform",
    #
    # Default scopes
    #   https://cloud.google.com/sdk/gcloud/reference/alpha/compute/instances/set-scopes#--scopes
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/pubsub",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/trace.append",
  ]
  service_account = [
    "579782627910-compute@developer.gserviceaccount.com",
    # "499205047883-compute@developer.gserviceaccount.com"
  ]
}

module "project-services" {
  source = "terraform-google-modules/project-factory/google//modules/project_services"

  count = local.number_of_projects

  project_id = local.project_ids[count.index]

  enable_apis = true
  activate_apis = [
    # "iam.googleapis.com",
    # "logging.googleapis.com",
    "osconfig.googleapis.com",
    # "containeranalysis.googleapis.com",
  ]
}

# resource "google_project_service" "compute_api" {
#   count = local.number_of_projects

#   project = local.project_ids[count.index]

#   service = "compute.googleapis.com"
#   # Wait for some time after the API has been enabled before continuing, as the
#   # call returns before the API has actually finished initializing.
#   provisioner "local-exec" {
#     command = "sleep 60"
#   }
# }

# resource "google_service_account" "default" {
#   account_id   = "tf-osconfig-vm"
#   display_name = "TF OSConfig VM Service Account"
#   count        = local.number_of_projects
#   project      = local.project_ids[count.index]
# }

#
#  The following roles are needed for the service account to be able to write instance metadata.
#
# resource "google_project_iam_binding" "log_writer" {
#   count   = local.number_of_projects
#   project = local.project_ids[count.index]
#   role    = "roles/logging.logWriter"
#   members = [
#     "serviceAccount:${google_service_account.default[count.index].email}"
#   ]
# }

# resource "google_project_iam_binding" "compute_viewer" {
#   count   = local.number_of_projects
#   project = local.project_ids[count.index]
#   role    = "roles/compute.viewer"
#   members = [
#     "serviceAccount:${google_service_account.default[count.index].email}"
#   ]
# }

# resource "google_project_iam_binding" "compute_instance_admin_v1" {
#   count   = local.number_of_projects
#   project = local.project_ids[count.index]
#   role    = "roles/compute.instanceAdmin.v1"
#   members = [
#     "serviceAccount:${google_service_account.default[count.index].email}"
#   ]
# }

# resource "google_project_iam_binding" "iam_service_account_user" {
#   count   = local.number_of_projects
#   project = local.project_ids[count.index]
#   role    = "roles/iam.serviceAccountUser"
#   members = [
#     "serviceAccount:${google_service_account.default[count.index].email}"
#   ]
# }

resource "google_compute_instance" "default" {
  name    = "tf-osconfig-linux-vm"
  count   = local.number_of_projects
  project = local.project_ids[count.index]

  machine_type = "e2-medium"
  zone         = local.zone

  boot_disk {
    auto_delete = true
    device_name = "tf-osconfig-linux-vm"

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20231101"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  network_interface {
    subnetwork = "projects/prod-dmz-host-project-391706/regions/asia-east1/subnetworks/tsmc-dmz-subnet-cloudmile-cloudrun"
  }

  service_account {
    email  = local.service_account[count.index]
    scopes = local.vm_service_account_scopes
  }

  metadata = {
    enable-guest-attributes = "TRUE"
    enable-osconfig         = "TRUE"
    osconfig-log-level      = "debug"
  }


  labels = {
    custon_label = "bastion"
  }
  tags = ["bastion"]
}

# resource "google_os_config_os_policy_assignment" "primary" {
#   instance_filter {
#     all = false
#     inclusion_labels {
#       labels = {
#         custon_label = "bastion"
#       }
#     }
#     inventories {
#       os_short_name = "ubuntu"
#       os_version    = "20.04"
#     }
#     inventories {
#       os_short_name = "ubuntu"
#       os_version    = "22.04"
#     }
#     inventories {
#       os_short_name = "windows"
#       os_version    = "10.*"
#     }
#     inventories {
#       os_short_name = "windows"
#       os_version    = "6.*"
#     }
#   }
#   location = local.zone
#   name     = "policy-assignment"

#   os_policies {
#     id   = "policy"
#     mode = "VALIDATION"

#     resource_groups {
#       resources {
#         id = "apt-to-yum"

#         repository {
#           apt {
#             archive_type = "DEB"
#             components   = ["doc"]
#             distribution = "debian"
#             uri          = "https://atl.mirrors.clouvider.net/debian"
#             gpg_key      = ".gnupg/pubring.kbx"
#           }
#         }
#       }
#       inventory_filters {
#         os_short_name = "centos"
#         os_version    = "8.*"
#       }

#       resources {
#         id = "exec1"
#         exec {
#           validate {
#             interpreter = "SHELL"
#             args        = ["arg1"]
#             file {
#               local_path = "$HOME/script.sh"
#             }
#             output_file_path = "$HOME/out"
#           }
#           enforce {
#             interpreter = "SHELL"
#             args        = ["arg1"]
#             file {
#               allow_insecure = true
#               remote {
#                 uri             = "https://www.example.com/script.sh"
#                 sha256_checksum = "c7938fed83afdccbb0e86a2a2e4cad7d5035012ca3214b4a61268393635c3063"
#               }
#             }
#             output_file_path = "$HOME/out"
#           }
#         }
#       }
#     }
#     allow_no_resource_group_match = false
#     description                   = "A test os policy"
#   }

#   rollout {
#     disruption_budget {
#       percent = 100
#     }

#     min_wait_duration = "3s"
#   }

#   description = "A test os policy assignment"
# }

module "agent_policy" {
  source  = "terraform-google-modules/cloud-operations/google//modules/agent-policy"
  version = "0.4.0"
  count   = local.number_of_projects

  project_id = local.project_ids[count.index]
  policy_id  = "ops-agents-example-policy"
  agent_rules = [
    {
      type               = "ops-agent"
      version            = "current-major"
      package_state      = "installed"
      enable_autoupgrade = true
    },
  ]
  group_labels = [
    {
      custon_label = "bastion"
    }
  ]
  os_types = [
    {
      short_name = "ubuntu"
      version    = "20.04"
    },
    {
      short_name = "ubuntu"
      version    = "22.04"
    },
    {
      short_name = "windows"
      version    = "10.*"
    },
    {
      short_name = "windows"
      version    = "6.*"
    }
  ]
}


