variable "name" {
  description = "Name of the instance"
  type        = string
  default     = "jump"
}

variable "subnetwork" {
  description = "Subnetwork to deploy the instance to"
  type        = string
  #   default     = "default"
}

variable "zone" {
  description = "Zone to deploy the instance to"
  type        = string
  default     = "asia-east1-a"
}

variable "project_id" {
  description = "Project ID"
  type        = string
  default     = "jump-gce"
}

variable "project_number" {
  description = "Project number"
  type        = string
  #   default     = "1234567890"
}


