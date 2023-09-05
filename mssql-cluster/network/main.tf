module "vpc" {
  source       = "terraform-google-modules/network/google"
  description  = "VPC network to deploy Active Directory"
  version      = "~> 7.0"
  project_id   = var.project_id
  network_name = var.vpc_name
  mtu          = 1460

  subnets = [
    {
      subnet_name           = var.subnet_name
      subnet_ip             = "10.10.10.0/24"
      subnet_region         = var.region
      subnet_private_access = "true"
    },
    {
      subnet_name           = var.sql_subnet_name
      subnet_ip             = "10.10.20.0/24"
      subnet_region         = var.region
      subnet_private_access = "true"
    }
  ]
}

module "firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = var.project_id
  network_name = module.vpc.network_name
  depends_on   = [module.vpc]

  rules = [{
    name        = "dbs204-fw-ad-controller"
    description = "allow ad connect ad"
    direction   = "INGRESS"
    priority    = 1000
    source_tags = ["ad"]
    target_tags = ["ad"]
    allow = [{
      protocol = "all"
    }]
    }, {
    name          = "dbs204-fw-ad-member"
    description   = "allow others connect ad"
    direction     = "INGRESS"
    priority      = 1000
    source_ranges = ["10.10.10.0/24", "10.10.20.0/24"]
    target_tags   = ["ad", "ad-member"]
    allow = [{
      protocol = "all"
    }]
    }, {
    name        = "dbs204-fw-sql"
    description = "allow sql connect sql"
    direction   = "INGRESS"
    priority    = 1000
    source_tags = ["sql"]
    target_tags = ["sql"]
    allow = [{
      protocol = "all"
    }]
    }, {
    name        = "dbs204-fw-fs"
    description = "allow sql connect fsw"
    direction   = "INGRESS"
    priority    = 1000
    source_tags = ["sql"]
    target_tags = ["sql"]
    allow = [{
      protocol = "tcp"
      ports    = ["445"]
    }]
    }, {
    name          = "dbs204-fw-sql-client"
    description   = "allow client connect sql"
    direction     = "INGRESS"
    priority      = 1000
    source_ranges = ["0.0.0.0/0"] # should change to client ip in prod
    target_tags   = ["sql"]
    allow = [{
      protocol = "tcp"
      ports    = ["1433"]
    }]
    }, {
    name          = "allow-rdp"
    description   = "allow client connect sql"
    direction     = "INGRESS"
    priority      = 1000
    source_ranges = ["0.0.0.0/0"] # should change to client ip in prod
    target_tags   = ["rdp"]
    allow = [{
      protocol = "tcp"
      ports    = ["3389"]
    }] }, {
    name        = "dbs204-fw-allow-all-between-wsfc-nodes"
    description = "wsfc connect wsfc"
    direction   = "INGRESS"
    priority    = 10000
    source_tags = ["wsfc"]
    target_tags = ["wsfc"]
    allow = [{
      protocol = "tcp"
      }, {
      protocol = "udp"
      }, {
      protocol = "icmp"
    }]
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
    }, {
    name          = "dbs204-fw-allow-sql-to-wsfc-nodes"
    description   = "db connect wsfc"
    direction     = "INGRESS"
    priority      = 10000
    source_ranges = [module.vpc.subnets["${var.region}/${var.sql_subnet_name}"].ip_cidr_range]
    target_tags   = ["wsfc-node"]
    allow = [{
      protocol = "tcp"
      ports    = ["1433"]
    }]
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
    }, {
    name          = "dbs204-fw-allow-health-check-to-wsfc-nodes"
    description   = "health check"
    direction     = "INGRESS"
    priority      = 10000
    source_ranges = ["130.211.0.0/22", "35.191.0.0/16"] // gcp health care ip
    target_tags   = ["wsfc-node"]
    allow = [{
      protocol = "tcp"
    }]
  }]
}

module "address" {
  source     = "terraform-google-modules/address/google"
  version    = "~> 3.1"
  project_id = var.project_id # Replace this with your project ID in quotes
  region     = var.region
  subnetwork = "projects/${var.project_id}/regions/${var.region}/subnetworks/${var.sql_subnet_name}"
  names      = ["wsfc", "wsfc-cluster"]
  addresses  = ["10.10.20.10", "10.10.20.11"]
  depends_on = [module.vpc]
}
