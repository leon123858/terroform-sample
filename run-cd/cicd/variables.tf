variable "git_token" {
  description = "The key to access github repo"
  type        = string
}
variable "build_sa" {
  description = "The service account for cloud build"
  type        = string
}
variable "git_app_id" {
  description = "id of the github app in repo. can find here https://github.com/settings/installations/<id>"
  type        = string
}
