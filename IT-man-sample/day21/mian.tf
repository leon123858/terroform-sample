provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_sql_database_instance" "instance" {
  name             = "${"my-postgres"}-sql"
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

resource "time_sleep" "wait_seconds" {
  depends_on = [google_sql_database_instance.instance]

  create_duration = "60s"
}

resource "google_sql_user" "iam_service_account_user" {
  # Note: for Postgres only, GCP requires omitting the ".gserviceaccount.com" suffix
  # from the service account email due to length limits on database usernames.
  name = trimsuffix("${"77786086397-compute@developer.gserviceaccount.com"}", ".gserviceaccount.com")
  /* name     = var.run-sa */
  instance = google_sql_database_instance.instance.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"

  depends_on = [time_sleep.wait_seconds]
}