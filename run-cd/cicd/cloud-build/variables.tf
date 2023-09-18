variable "git-url" {
  description = "The url for project"
  type        = string
}
variable "file" {
  description = "The file path from root of cloudBuild.yaml"
  type        = string
}
variable "region" {
  description = "The region where build locate"
  type        = string
}
variable "name" {
  description = "name of the trigger"
  type        = string
}
variable "connection-id" {
  description = "id of the github connection"
  type        = string
}
