provider "google" {
  project = var.project_id
  region  = var.region
}

module "network" {
  source          = "./network"
  project_id      = var.project_id
  vpc_name        = var.vpc_name
  region          = var.region
  sql_subnet_name = var.sql_subnet_name
  subnet_name     = var.subnet_name
}

module "vms" {
  source          = "./instances"
  project_id      = var.project_id
  vpc_name        = var.vpc_name
  region          = var.region
  subnet_name     = var.subnet_name
  sql_subnet_name = var.sql_subnet_name
  vm_ad1_name     = var.vm_ad1_name
  vm_ad2_name     = var.vm_ad2_name
  vm_zone1_name   = var.zone_1
  vm_zone2_name   = var.zone_2
  vm_zone3_name   = var.zone_3
  vm_db1_name     = var.vm_db1_name
  vm_db2_name     = var.vm_db2_name
  vm_db3_name     = var.vm_db3_name
  vm_fsw1         = var.vm_fsw1
  group1_name     = var.group_name1
  group2_name     = var.group_name2

  depends_on = [module.network]
}
