provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
  name   = "default"
}

resource "aws_db_instance" "northwind-db" {
    identifier = "northwind-db"
    name = "northwind"
    instance_class = "db.t2.small"
    allocated_storage = 5
    engine = "postgres"
    engine_version = "11.4"
    skip_final_snapshot = true
    publicly_accessible = true
    vpc_security_group_ids = ["${data.aws_security_group.default.id}"]
    username = "postgres"
    password = "postgres"
}
