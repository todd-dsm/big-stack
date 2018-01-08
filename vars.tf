# -----------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# vim: et:ts=2:sw=2
# -----------------------------------------------------------------------------
variable "region" {
  description = "Default Region"
  # Defined = terraform.tfvars
}

variable "project" {
  description = "The Project Name"
  # Defined = terraform.tfvars
}

variable "domain_name" {
  description = "Our Domain Name"
  # Defined = terraform.tfvars
}

variable "environment" {
  description = "The Deployment Environments"
  # Defined = terraform.tfvars
}

# -----------------------------------------------------------------------------
# Network Definitions/Defaults
# -----------------------------------------------------------------------------
# Declare the data source
data "aws_availability_zones" "available" {}

# The Office
variable "office_gateway" {
  description = "CIDR blocks accessed publically."
  # Defined = terraform.tfvars
}

# Admin COMMS port
variable "comms_port" {
  description = "The port the server will use for SSH requests"
  default     = 22
}

# Web Calls
variable "http_port" {
  description = "The port used for outbound HTTP service requests"
  default     = 80
}

# Secure Web Calls
variable "https_port" {
  description = "The port used for outbound HTTPS service requests"
  default     = 443
}

# Define the app port
variable "service_port" {
  description = "The port the server will use for HTTP requests"
  default     = 8000
}

# -----------------------------------------------------------------------------
# CoreOS Stuff
variable "channel" {
  default = "stable"
}

variable "virtualization_type" {
  default = "hvm"
}

# -----------------------------------------------------------------------------

variable "pathKeyPriv" {
  default = "~/.ssh/id_rsa"
}

variable "pathKeyPub" {
  default = "~/.ssh/id_rsa.pub"
}

#variable "pathKeyBuilderPriv" {
#  default = "~/.ssh/builder"
#}
#variable "pathKeyBuilderPub" {
#  default = "~/.ssh/builder.pub"
#}
variable "instAdminUser" {
  default = "ubuntu"
}


# -----------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# -----------------------------------------------------------------------------
# AMIs by Region
variable "AMIS" {
  type = "map"

  default = {
    us-east-1 = "ami-2808313f" # N. Virginia
    us-west-1 = "ami-be376ecd" # NoCal
    us-west-2 = "ami-7df25b1d" # Oregon
  }
}


