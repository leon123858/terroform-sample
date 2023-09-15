variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}
variable "region" {
  description = "The region of the workflow."
  type        = string
}
variable "file" {
  description = "The path for workflow file."
  type        = string
}
variable "account" {
  description = "The self link for account."
  type        = string
}
