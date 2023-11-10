variable "project_id" {
  description = "value of project_id"
}
variable "region" {
  description = "value of region"
}
variable "git_url" {
  description = "get repo url in gethub. ex: https://github.com/leon123858/bi-event-driven-web-connection-PoC"
}
variable "git_app_id" {
  description = "get app id in github, url in configure git app. ex: 36856157"
}
variable "git_token" {
  description = "get access token in github, should have repo, read:user [, read:org] permission"
}
variable "image_path" {
  description = "get image path in repo. ex: private-gke-mail/mail-server"
}
