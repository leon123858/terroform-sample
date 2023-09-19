variable "file" {
  description = "The file path from root of project in repo ex:docker-sample/Dockerfile"
  type        = string
}
variable "region" {
  description = "The region where build locate"
  type        = string
}
variable "name" {
  description = "name of the target container"
  type        = string
}
variable "repo-id" {
  description = "id of the github repo"
  type        = string
}
variable "repo-name" {
  description = "name of the github repo"
  type        = string
}
