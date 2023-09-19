resource "google_cloudbuild_trigger" "manual-trigger" {
  location = var.region
  name     = "${var.name}-triggrt"

  source_to_build {
    repository = var.repo-id
    ref        = "refs/heads/main"
    repo_type  = "GITHUB"
  }

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "--no-cache", "-t", "$_AR_HOSTNAME/$PROJECT_ID/$_REPO_NAME/$_REPO_NAME/$_SERVICE_NAME:$COMMIT_SHA", "${var.name}", "-f", "${var.file}"]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "$_AR_HOSTNAME/$PROJECT_ID/$_REPO_NAME/$_REPO_NAME/$_SERVICE_NAME:$COMMIT_SHA"]
    }
    step {
      name = "gcr.io/google.com/cloudsdktool/cloud-sdk:slim"
      args = ["run", "deploy", "${var.name}", "--image", "$_AR_HOSTNAME/$PROJECT_ID/$_REPO_NAME/$_REPO_NAME/$_SERVICE_NAME:$COMMIT_SHA", "--region", "${var.region}", "--platform", "managed", "--allow-unauthenticated"]
    }

    substitutions = {
      _SERVICE_NAME : var.name
      _DEPLOY_REGION : "${var.region}"
      _REPO_NAME : "${var.repo-name}"
      _AR_HOSTNAME : "${var.region}-docker.pkg.dev"
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
}
