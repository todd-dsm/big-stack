# ------------------------------------------------------------------------------
# This file actuates a Terraform build for a single VPC with multiple subnets.
# vim: et:ts=2:sw=2
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# CONFIGURE THE AWS CONNECTION AND AUTH
# ------------------------------------------------------------------------------
provider "aws" {
  region = "${var.region}"
}

# -----------------------------------------------------------------------------
# Configure the VPC(s)
# -----------------------------------------------------------------------------
# DEV
# -----------------------------------------------------------------------------
module "vpc" {
  source          = "github.com/terraform-community-modules/tf_aws_vpc?ref=v1.0.11"
  name            = "${var.project}"
  cidr            = "10.0.0.0/16"
  public_subnets  = ["10.0.64.0/18"]
  private_subnets = ["10.0.128.0/19"]
  azs             = ["us-west-2a"]

  # Options
  enable_nat_gateway = "true"

  tags {
    "Name"        = "${var.project}"
    "Environment" = "${var.environment}"
    "Terraform"   = "true"
  }
}

# -----------------------------------------------------------------------------
# AWS Security Groups
# -----------------------------------------------------------------------------
# Allow access on ports: 80, 443, 8080 and 1099
module "sg_web" {
  source              = "github.com/terraform-community-modules/tf_aws_sg//sg_web"
  security_group_name = "${var.project}-web"
  vpc_id              = "${module.vpc.vpc_id}"
  source_cidr_block   = ["${var.source_cidr_block}"]

  # FIX: ? - cannot tags SGs; do we care?
}

# SSH Access
# FIX: restrict to bastion later
module "sg_ssh" {
  source              = "github.com/terraform-community-modules/tf_aws_sg//sg_ssh"
  security_group_name = "${var.project}-ssh"
  vpc_id              = "${module.vpc.vpc_id}"
  source_cidr_block   = ["${var.source_cidr_block}"]

  # FIX: ? - cannot tag SGs; do we care?
}

# -----------------------------------------------------------------------------
# NETWORK SERVICES: DNS
# FIX: modularize
# -----------------------------------------------------------------------------
resource "aws_route53_zone" "main" {
  name = "ptest.us"
}

resource "aws_route53_zone" "dev" {
  name = "dev.ptest.us"

  #private_zone = true                                     # FIX: should work

  tags {
    "Name"        = "${var.project}"
    "Environment" = "${var.environment}"
    "Terraform"   = "true"
  }
}

resource "aws_route53_record" "dev-ns" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "dev.ptest.us"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.dev.name_servers.0}",
    "${aws_route53_zone.dev.name_servers.1}",
    "${aws_route53_zone.dev.name_servers.2}",
    "${aws_route53_zone.dev.name_servers.3}",
  ]
}

# -----------------------------------------------------------------------------
# NETWORK SERVICES: DHCP
# FIX: modularize
# -----------------------------------------------------------------------------
#resource "aws_vpc_dhcp_options" "dev" {
#  source              = "github.com/todd-dsm/tf_aws_vpc_dhcp_options?ref=v0.1"
#  domain_name         = "dev.ptest.us"
#  domain_name_servers = ["205.251.194.141"]
#
#  #  domain_name_servers  = [
#  #    "${aws_route53_zone.dev.name_servers.0}",
#  #    "${aws_route53_zone.dev.name_servers.1}",
#  #    "${aws_route53_zone.dev.name_servers.2}",
#  #    "${aws_route53_zone.dev.name_servers.3}"
#  #  ]
#  ntp_servers = ["104.154.189.119"]
#
#  #  ntp_servers          = [
#  #    "0.amazon.pool.ntp.org",
#  #    "1.amazon.pool.ntp.org",
#  #    "2.amazon.pool.ntp.org",
#  #    "3.amazon.pool.ntp.org"
#  #  ]
#
#  tags {
#    "Name"        = "${var.project}"
#    "Environment" = "${var.environment}"
#    "Terraform"   = "true"
#  }
#}
#
#resource "aws_vpc_dhcp_options_association" "dns_resolver" {
#  vpc_id          = "${module.vpc.vpc_id}"
#  dhcp_options_id = "${aws_vpc_dhcp_options.dev.id}"
#}

# -----------------------------------------------------------------------------
# Find the latest AMI; NOTE: MUST produce only 1 AMI ID.
# -----------------------------------------------------------------------------
#data "aws_ami" "base_ami" {
#  most_recent = true
#  owners      = ["self"]
#
#  filter {
#    name   = "architecture"
#    values = ["x86_64"]
#  }
#
#  filter {
#    name   = "image-type"
#    values = ["machine"]
#  }
#
#  filter {
#    name   = "name"
#    values = ["base-debian"]
#  }
#
#  filter {
#    name   = "state"
#    values = ["available"]
#  }
#}

