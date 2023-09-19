resource "google_sql_database_instance" "instance" {
  name             = "${var.service_name}-sql"
  region           = var.region
  database_version = "POSTGRES_15"
  settings {
    tier      = "db-f1-micro"
    disk_type = "PD_HDD"
    disk_size = 10
    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
  }

  deletion_protection = "false"
}

resource "time_sleep" "wait_15_seconds" {
  depends_on = [google_sql_database_instance.instance]

  create_duration = "15s"
}

resource "google_sql_user" "iam_service_account_user" {
  # Note: for Postgres only, GCP requires omitting the ".gserviceaccount.com" suffix
  # from the service account email due to length limits on database usernames.
  name = trimsuffix(var.run-sa, ".gserviceaccount.com")
  /* name     = var.run-sa */
  instance = google_sql_database_instance.instance.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"

  depends_on = [time_sleep.wait_15_seconds]
}

resource "google_cloud_run_v2_service" "default" {
  name     = var.service_name
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = var.run-sa

    scaling {
      max_instance_count = 3
      min_instance_count = 0
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.instance.connection_name]
      }
    }

    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      env {
        name  = "DB_IAM_USER"
        value = google_sql_user.iam_service_account_user.name
      }
      env {
        name  = "DB_NAME"
        value = var.db-name
      }
      env {
        name  = "INSTANCE_CONNECTION_NAME"
        value = google_sql_database_instance.instance.connection_name
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }
  }



  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
  depends_on = [google_sql_user.iam_service_account_user]
}


