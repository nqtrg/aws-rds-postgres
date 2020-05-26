# Doc: https://www.terraform.io/docs/providers/aws/r/db_instance.html
# Example: https://github.com/terraform-aws-modules/terraform-aws-rds/blob/v2.12.0/examples/replica-postgres/main.tf

provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"
}

data "aws_vpc" "default" {
  default = true
}

resource "random_string" "northwind-db-password" {
  length  = 32
  upper   = true
  number  = true
  special = false
}

resource "aws_security_group" "northwind" {
  vpc_id      = data.aws_vpc.default.id
  name        = "northwind"
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
  vpc_security_group_ids = [aws_security_group.northwind.id]
  username               = "ngutruong"
  password               = random_string.northwind-db-password.result
  

  # Backups are required in order to create a replica
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  backup_retention_period = 1
}

resource "aws_db_instance" "northwind-ngutruong-read"  {
  identifier             = "northwind-ngutruong-read"
  replicate_source_db    = aws_db_instance.northwind-ngutruong.identifier  ## refer to the master instance
  name                   = "northwind"
  instance_class         = "db.t2.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "11.4"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.northwind.id]

  # Username and password must not be set for replicas
  username = ""
  password = ""

  # disable backups to create DB faster
  backup_retention_period = 0
}
