variable "git_token" {
  description = "The key to access github repo"
  type        = string
  default     = "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"
}
variable "build_sa" {
  description = "The service account for cloud build"
  type        = string
  default     = "service-77786086397@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}
variable "git_app_id" {
  description = "id of the github app in repo. can find here https://github.com/settings/installations/<id>"
  type        = string
  default     = "36856157"
}
