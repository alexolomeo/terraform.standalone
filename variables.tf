/*
  Definition of Variables
  List Variables to configuracion network and access
*/

variable "projectname" {
  description = "AWS Project Name."
  default = "CUSTUMER_DEMO"
}

variable "profile" {
  description = "AWS Profile Gard Access."
  default = "aws-profile"
}
variable "aws_region" {
  description = "AWS region from Latinoamerica Access."
  default = "us-west-2"
}

variable "access_key" {
  description = "AWS Access Key."
  default = ""
}

variable "secret_key" {
  description = "AWS Secret Key."
  default = ""
}

variable "ami-app1" {
  description = "AMI Com"
  default = "ami-"
}

variable "ami-app2" {
  description = "AMI Erp"
  default = "ami-"
}

variable "instance-type-x64" { 
  default = {
    "large" = "m5.large",
    "medium" = "t2.medium",
    "small" = "t2.small"
  }
}

variable "instance-type-arm64" { 
  default = {
    "large" = "t4g.large",
    "medium" = "t4g.medium",
    "small" = "t4g.small"
  }
}

variable "environment" { 
  default = {
    "production" = "PRODUCTION",
    "integration" = "INTEGRATION",
    "development" = "DEVELOPMENT"
  }
}

variable "network_access" {
  description = "List of CIDR blocks to access via SSH, PostgreSQL, Jboss Console from Customer network"
  default = ["200.0.0.0/8","200.0.0.0/8"]
}

variable "vpc_cidr" { default = "10.10.0.0/16" }

variable "subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  default = {
    "production-network" = "10.10.100.0/24",
    "integration-network" = "10.10.200.0/24",
    "development-network" = "10.10.10.0/24"
  }
}

variable "external_nameserver" { default = "8.8.8.8" }


variable "PUBLIC_KEY_APP" {
  default = "KEY-APP.pub"
}

variable "db_credential" {
  description = "Credential db com"
  default = {
    "username" = "usermain",
    "password" = "*******"
  }
}

