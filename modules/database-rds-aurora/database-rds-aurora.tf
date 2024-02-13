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

locals {
  name              = "${var.identifier}"
  apply_immediately = true
  engine            = "aurora-postgresql"
  engine_version    = "12.15"
  family            = "${local.engine}${split(".", local.engine_version)[0]}"
}

resource "aws_rds_cluster_parameter_group" "cluster_parameters" {
  name_prefix = "${local.name}-"
  family      = local.family

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_parameter_group" "db_parameters" {
  name_prefix = "${local.name}-"
  family      = local.family

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 2
  identifier         = "${var.identifier}-${count.index}"
  cluster_identifier = aws_rds_cluster.default.id
  instance_class     = "db.t4g.medium"
  publicly_accessible      = true
  engine             = aws_rds_cluster.default.engine
  engine_version     = aws_rds_cluster.default.engine_version
  db_parameter_group_name = aws_db_parameter_group.db_parameters.name
}

resource "aws_rds_cluster" "default" {
  cluster_identifier = "${var.identifier}"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  database_name    = "${var.database_name}"
  master_username  = "${var.master_username}"
  master_password  = "${var.master_password}"
  engine           = "aurora-postgresql"
  engine_version   = "12.15"
  db_subnet_group_name     = "${var.db_subnet_group_name}"
  vpc_security_group_ids   = ["${aws_security_group.com_db.id}"]
  db_cluster_parameter_group_name  = aws_rds_cluster_parameter_group.cluster_parameters.name
}
