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
variable "vm_ad1_name" {
  description = "Name of the ad1."
  type        = string
}
variable "vm_ad2_name" {
  description = "Name of the ad2."
  type        = string
}
variable "vm_zone1_name" {
  description = "Name of the zone1."
  type        = string
}
variable "vm_zone2_name" {
  description = "Name of the zone2."
  type        = string
}
variable "vm_zone3_name" {
  description = "Name of the zone3."
  type        = string
}
variable "vm_db1_name" {
  description = "Name of the db1."
  type        = string
}
variable "vm_db2_name" {
  description = "Name of the db2."
  type        = string
}
variable "vm_db3_name" {
  description = "Name of the db3."
  type        = string
}
variable "vm_fsw1" {
  description = "Name of the fsw1."
  type        = string
}
variable "group1_name" {
  description = "Name of the group1."
  type        = string
}
variable "group2_name" {
  description = "Name of the group2."
  type        = string
}
