resource "aws_security_group" "firewall_app" {
  name        = "FIREWALL ${upper(var.environment)} ${upper(var.name)} APP"
  description = "Firewall for APP"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.cidr_blocks}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app-server" {
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.firewall_app.id}"]
  key_name               = "${var.keypair}"

  tags {
    Name = "${upper(var.environment)} ${upper(var.name)} APP"
  }
}

output "hostname" {
  value = "${aws_instance.app-server.private_dns}"
}

resource "aws_security_group" "firewall_elb" {
  name        = "FIREWALL ${upper(var.environment)} ${upper(var.name)} LOADBALANCER"
  description = "Firewall for APP"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_elb" "app_elb" {
  name = "${lower(var.name)}-${lower(var.environment)}-balancer"
  subnets 	  = ["${var.subnet_id}"]
  security_groups = ["${aws_security_group.firewall_elb.id}"]
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }


  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:80"
    interval = 30
  }

  instances = ["${aws_instance.app-server.id}"]

  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags {
    Name = "${lower(var.name)}"
  }
}
