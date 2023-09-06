variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
  default     = "tw-rd-ca-leon-lin"
}
variable "vpc_name" {
  description = "The vpc_name of the project."
  type        = string
  default     = "dbs204-vpc"
}
variable "region" {
  description = "Name of the region."
  type        = string
  default     = "asia-east1"
}
variable "subnet_name" {
  description = "Name of the subnet_name have AD."
  type        = string
  default     = "dbs204-asia-east1-config"
}
variable "sql_subnet_name" {
  description = "Name of the subnet_name have db."
  type        = string
  default     = "dbs204-asia-east1-database"
}
variable "zone_1" {
  description = "Name of the zone_1."
  type        = string
  default     = "asia-east1-a"
}
variable "zone_2" {
  description = "Name of the zone_2."
  type        = string
  default     = "asia-east1-b"
}
variable "zone_3" {
  description = "Name of the zone_3."
  type        = string
  default     = "asia-east1-c"
}
variable "vm_ad1_name" {
  description = "Name of the ad1."
  type        = string
  default     = "dbs204-vm-ad1"
}
variable "vm_ad2_name" {
  description = "Name of the ad2."
  type        = string
  default     = "dbs204-vm-ad2"
}
variable "vm_db1_name" {
  description = "Name of the db1."
  type        = string
  default     = "dbs204-sql1"
}
variable "vm_db2_name" {
  description = "Name of the db2."
  type        = string
  default     = "dbs204-sql2"
}
variable "vm_db3_name" {
  description = "Name of the db3."
  type        = string
  default     = "dbs204-sql3"
}
variable "vm_fsw1" {
  description = "Name of the fsw1."
  type        = string
  default     = "dbs204-vm-fsw1"
}
