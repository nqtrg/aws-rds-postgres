provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

resource "random_string" "northwind-db-password" {
  length = 32
  upper = true
  number = true
  special = false
}

resource "aws_security_group" "northwind" {
  vpc_id = "${data.aws_vpc.default.id}"
  name   = "northwind"
  description = "Allow all inbound for Postgres"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "northwind-ngutruong" {
  identifier             = "northwind-ngutruong"
  name                   = "northwind"
  instance_class         = "db.t2.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "11.4"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = ["${aws_security_group.northwind.id}"]
  username               = "ngutruong"
  password               = "${random_string.northwind-db-password.result}"
}
