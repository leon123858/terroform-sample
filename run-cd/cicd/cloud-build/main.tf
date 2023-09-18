resource "google_cloudbuildv2_repository" "my-repository" {
  name              = "${var.name}-repo"
  location          = var.region
  parent_connection = var.connection-id
  remote_uri        = "${var.git-url}.git"
}

resource "google_cloudbuild_trigger" "manual-trigger" {
  location = var.region
  name     = "${var.name}-triggrt"

  source_to_build {
    repository = google_cloudbuildv2_repository.my-repository.id
    ref        = "refs/heads/main"
    repo_type  = "GITHUB"
  }

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "$_AR_HOSTNAME/$PROJECT_ID/cloud-run-source-deploy/$REPO_NAME/$_SERVICE_NAME:$COMMIT_SHA", "."]
    }

    substitutions = {
      _SERVICE_NAME : var.name
      _DEPLOY_REGION : "${var.region}"
      _AR_HOSTNAME : "${var.region}-docker.pkg.dev"
      /* _PLATFORM : managed */
    }

    artifacts {
      images = ["gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA"]
    }
  }


  // If this is set on a build, it will become pending when it is run, 
  // and will need to be explicitly approved to start.
  approval_config {
    approval_required = false
  }

  depends_on = [google_cloudbuildv2_repository.my-repository]
}
