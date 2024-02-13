/*
  AUTHOR alexolomeo@gmail.com
  VPC Definition 
  Base for VPC
*/

provider "aws" {
#  profile = "${var.profile}"
#  region = "${var.region}"
#  version = "~> 2.55"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.aws_region}"
}


resource "aws_vpc" "network" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = "true" 
  enable_dns_support = "true"
  tags = {
        Name = "${lower(var.projectname)}-network"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.network.id}"
  tags = {
        Name = "${lower(var.projectname)}-gateway"
  }
}

resource "aws_default_route_table" "default_routing" {
  default_route_table_id = "${aws_vpc.network.default_route_table_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags = {
        Name = "${lower(var.projectname)}-route"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "production" {
  vpc_id = "${aws_vpc.network.id}"
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "${lookup(var.subnet_cidrs, "production-network")}"
  map_public_ip_on_launch = true
  tags = {
        Name = "${lower(var.projectname)}-production-environment"
  }
}

resource "aws_subnet" "integration" {
  vpc_id = "${aws_vpc.network.id}"
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block = "${lookup(var.subnet_cidrs, "integration-network")}"
  map_public_ip_on_launch = true
  tags = {
        Name = "${lower(var.projectname)}-integration-environment"
  }
}

resource "aws_subnet" "development" {
  vpc_id = "${aws_vpc.network.id}"
  availability_zone = data.aws_availability_zones.available.names[2]
  cidr_block = "${lookup(var.subnet_cidrs, "development-network")}"
  tags = {
        Name = "${lower(var.projectname)}-development-enviroment"
  }
}



/*
  RDS SUBNET GROUP
*/
resource "aws_db_subnet_group" "subnet-db" {
    name = "subnet-terraform"
    description = "Customer Subnet"
    subnet_ids = ["${aws_subnet.production.id}", "${aws_subnet.integration.id}", "${aws_subnet.development.id}"]
    tags = {
        Name = "SUBNET RDS"
    }
}

/*
  ADD MANY INTANCES BELLOW, RDS-AURORA + EC2-ELB or RDS + EC2-ALB or RDS + RDS-AURORA + EC2-ALB
  READ THE EXAMPLE ON README.md
*/


/*
  RDS MODULE AURORA PRODUCTION APP1
*/

module "production-databata-1" {
  source    = "./modules/database-rds-aurora"
  name      = "database-1"
  identifier = "${lower(var.projectname)}-app1-prod"
  vpc_id    = "${aws_vpc.network.id}"
  subnet_id = "${aws_subnet.production.id}"
  db_subnet_group_name = "${aws_db_subnet_group.subnet-db.name}"
  master_username  = "${lookup(var.db_credential, "username")}"
  master_password  = "${lookup(var.db_credential, "password")}"
  environment	= "${lookup(var.environment, "production")}"
  database_name      = "name1db"
}


/*
  INSTANCE PRODUCTION APP1
*/
resource "aws_key_pair" "appkey1" {
  key_name = "KEY-${upper(var.projectname)}-APP1"
  public_key = "${file("./keys/${var.PUBLIC_KEY_APP}")}"
}

module "production-app-1" {
  source    = "./modules/application-ec2-elb"
  name 	    = "APP1"
  ami       = "${var.ami-app1}"
  instance_type = "${lookup(var.instance-type-x64, "medium")}"
  vpc_id    = "${aws_vpc.network.id}"
  subnets = ["${aws_subnet.production.id}", "${aws_subnet.integration.id}"]
  subnet_id = "${aws_subnet.production.id}"
  keypair = "${aws_key_pair.appkey1.key_name}"
  cidr_blocks    = "${var.network_access}"
  environment	= "${lookup(var.environment, "production")}"
}

/*
  RDS MODULE PRODUCTION APP2 AS SINGLE MODE 
*/

module "production-database-2" {
  source    = "./modules/database-rds"
  name      = "database-2"
  identifier = "${lower(var.projectname)}-app2-prod"
  vpc_id    = "${aws_vpc.network.id}"
  subnet_id = "${aws_subnet.production.id}"
  db_subnet_group_name = "${aws_db_subnet_group.subnet-db.name}"
  master_username  = "${lookup(var.db_credential, "username")}"
  master_password  = "${lookup(var.db_credential, "password")}"
  environment	= "${lookup(var.environment, "production")}"
  database_name      = "name2db"
}


/*
  INSTANCE PRODUCTION EC2 WITH ARM INSTANCES
*/
resource "aws_key_pair" "appkey2" {
  key_name = "KEY-${upper(var.projectname)}-APP2"
  public_key = "${file("./keys/${var.PUBLIC_KEY_APP}")}"
}

module "production-app-2" {
  source    = "./modules/application-ec2-alb"
  name 	    = "APP2"
  ami       = "${var.ami-app2}"
  instance_type = "${lookup(var.instance-type-arm64, "medium")}"
  vpc_id    = "${aws_vpc.network.id}"
  subnets = ["${aws_subnet.production.id}", "${aws_subnet.integration.id}"]
  subnet_id = "${aws_subnet.production.id}"
  keypair = "${aws_key_pair.appkey2.key_name}"
  cidr_blocks    = "${var.network_access}"
  environment	= "${lookup(var.environment, "production")}"
}

