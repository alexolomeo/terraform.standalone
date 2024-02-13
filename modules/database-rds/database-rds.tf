resource "aws_security_group" "security_group_db" {
  name        = "FIREWALL ${upper(var.environment)} ${upper(var.name)} DATABASE"
  description = "Firewall for DB"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_db_instance" "rds_app" {  
  allocated_storage        = 100 # gigabytes
  backup_retention_period  = 7   # in days
  engine                   = "postgres"
  engine_version           = "12.15"
  identifier               = "${var.identifier}"
  instance_class           = "db.t2.small"
  multi_az                 = false
  name                     = "${var.name}"
  port                     = 5432
  publicly_accessible      = true
  storage_encrypted        = true # you should always do this
  storage_type             = "gp2"
  username                 = "${var.username}"
  password                 = "${var.password}"
  skip_final_snapshot      = "true"
  parameter_group_name     = "default.postgres12" # if you have tuned it
  db_subnet_group_name     = "${var.db_subnet_group_name}"
  vpc_security_group_ids   = ["${aws_security_group.syscom_db.id}"]
}

