variable "secret_id" {
  description = "The unique ID of secret manager in the project"
  type        = string
}
variable "git_token" {
  description = "The key to access github repo"
  type        = string
}
variable "build_sa" {
  description = "The service account for cloud build"
  type        = string
}
variable "region" {
  description = "Name of the region."
  type        = string
}
variable "name" {
  description = "Name of the connection."
  type        = string
}
variable "git_app_id" {
  description = "id of the github app in repo. can find here https://github.com/settings/installations/<id>"
  type        = string
}
variable "git-url" {
  description = "The url for project"
  type        = string
}
