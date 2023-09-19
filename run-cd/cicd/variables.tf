variable "git_token" {
  description = "The key to access github repo"
  type        = string
}
variable "build_sa" {
  description = "The service account for cloud build connection"
  type        = string
}
variable "git_app_id" {
  description = "id of the github app in repo. can find here https://github.com/settings/installations/<id>"
  type        = string
}
variable "builder_sa" {
  description = "The service account for cloud build deploy"
  type        = string
}
variable "service_name" {
  description = "The name for cloud run"
  type        = string
}
