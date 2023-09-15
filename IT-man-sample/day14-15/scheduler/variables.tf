variable "project_id" {
  description = "project id"
  type        = string
}
variable "email" {
  description = "The email for service accunt to invoke workflow."
  type        = string
}
variable "region" {
  description = "The region of the workflow."
  type        = string
}
variable "name" {
  description = "The name of the workflow."
  type        = string
}
variable "bucket" {
  description = "The path for bucket."
  type        = string
}
variable "db" {
  description = "The name for firestore db."
  type        = string
}
