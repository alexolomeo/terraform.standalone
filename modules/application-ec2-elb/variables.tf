variable "vpc_id" {}
  
variable "subnet_id" {}

variable "name" {}

variable "keypair" {}

variable "subnets"   { type = "list"}

variable "instance_type" {}

variable "ami" {}

variable "cidr_blocks" { type = "list"}

variable "environment" {}


