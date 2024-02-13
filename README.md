# terraform.standalone
terraform solution for automation a standalone service with ec2 and RDS.

Add instances as this example for Aurora instancias an changes the value of variable.tf

```yml
/*
  RDS MODULE AURORA 
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
  INSTANCE PRODUCTION 
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
```

Add instances as this example for RDS instancias an changes the value of variable.tf

```yml
/*
  RDS AS SINGLE MODE
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
  environment   = "${lookup(var.environment, "production")}"
  database_name      = "name2db"
} 


/*
  INSTANCE EC2 WITH ARM INSTANCES
*/
resource "aws_key_pair" "appkey2" {
  key_name = "KEY-${upper(var.projectname)}-APP2"
  public_key = "${file("./keys/${var.PUBLIC_KEY_APP}")}"
} 
        
module "production-app-2" {
  source    = "./modules/application-ec2-alb"
  name      = "APP2"
  ami       = "${var.ami-app2}"
  instance_type = "${lookup(var.instance-type-arm64, "medium")}"
  vpc_id    = "${aws_vpc.network.id}"
  subnets = ["${aws_subnet.production.id}", "${aws_subnet.integration.id}"]
  subnet_id = "${aws_subnet.production.id}"
  keypair = "${aws_key_pair.appkey2.key_name}"
  cidr_blocks    = "${var.network_access}"
  environment   = "${lookup(var.environment, "production")}"
} 


```
