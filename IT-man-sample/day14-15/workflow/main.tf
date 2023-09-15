resource "google_workflows_workflow" "backup" {
  name            = "backup-firestore"
  region          = var.region
  description     = "A sample backup action for firestore"
  service_account = var.account
  source_contents = file(var.file)
}
