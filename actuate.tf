# -----------------------------------------------------------------------------
# This file actuates a Terraform build for a single VPC with multiple subnets.
# vim: et:ts=2:sw=2
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# CONFIGURE THE AWS CONNECTION AND AUTH
# -----------------------------------------------------------------------------
provider "aws" {
  region = "${var.region}"
}

# -----------------------------------------------------------------------------
# Configure the VPC
# ------------------------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.9.1"

  name = "${var.project}"

  cidr = "10.0.0.0/16"

  azs                 = ["${data.aws_availability_zones.available.id}"]
  private_subnets     = ["10.0.1.0/24",  "10.0.2.0/24",  "10.0.3.0/24"]
  public_subnets      = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  database_subnets    = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
  #elasticache_subnets = ["10.0.31.0/24", "10.0.32.0/24", "10.0.33.0/24"]

  create_database_subnet_group = true

  enable_nat_gateway = true
  #enable_vpn_gateway = true

  #enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true

  enable_dns_support = true
  enable_dns_hostnames = true

  enable_dhcp_options              = true
  dhcp_options_domain_name         = "${var.domain_name}"
  dhcp_options_domain_name_servers = ["127.0.0.1", "10.0.0.2"]

  tags = {
    Owner       = "tthomas"
    Environment = "${var.environment}"
    Name        = "${var.project}"
  }
}

# -----------------------------------------------------------------------------
# Access Points In & Out
# ------------------------------------------------------------------------------
//module "security-group" {
//  source  = "terraform-aws-modules/security-group/aws"
//  version = "1.6.0"
//
//  # insert the 2 required variables here
//}