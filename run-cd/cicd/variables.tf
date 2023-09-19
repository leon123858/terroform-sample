variable "git_token" {
  description = "The key to access github repo"
  type        = string
  default     = ""
}
variable "build_sa" {
  description = "The service account for cloud build connection"
  type        = string
  default     = "service-77786086397@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}
variable "git_app_id" {
  description = "id of the github app in repo. can find here https://github.com/settings/installations/<id>"
  type        = string
  default     = "36856157"
}
variable "builder_sa" {
  description = "The service account for cloud build deploy"
  type        = string
  default     = "77786086397@cloudbuild.gserviceaccount.com"
}
variable "service_name" {
  description = "The name for cloud run"
  type        = string
  default     = "docker-sample"
}
