variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}
variable "vpc_name" {
  description = "The vpc_name of the project."
  type        = string
}
variable "region" {
  description = "Name of the region."
  type        = string
}
variable "subnet_name" {
  description = "Name of the subnet_name have AD."
  type        = string
}
variable "sql_subnet_name" {
  description = "Name of the subnet_name have db."
  type        = string
}