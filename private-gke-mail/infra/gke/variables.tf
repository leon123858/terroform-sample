variable "project_id" {
  description = "value of project_id"
}
variable "region" {
  description = "value of region"
}
variable "subnet_name" {
  description = "value of subnet_name"
  default     = "gke-subnet-1"
}
variable "subnet_ip" {
  description = "value of subnet_ip"
  default     = "192.168.1.0/24"
}
variable "custom_network" {
  description = "value of custom_network"
  default     = "custom-network1"
}
variable "gke_name" {
  description = "value of gke_name"
  default     = "gke-cluster-1"
}
variable "gke_location" {
  description = "value of gke_location"
  default     = "asia-east1-a"
}
