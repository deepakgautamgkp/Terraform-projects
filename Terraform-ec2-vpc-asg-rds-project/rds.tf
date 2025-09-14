
resource "aws_db_subnet_group" "default" {
name = "${var.project}-db-subnet"
subnet_ids = values(aws_subnet.private)[*].id
tags = { Name = "${var.project}-db-subnet" }
}


resource "aws_db_instance" "mysql" {
identifier = "${var.project}-db"
engine = "mysql"
instance_class = var.db_instance_class
allocated_storage = var.db_allocated_storage
username = var.db_username
password = var.db_password
skip_final_snapshot = true
vpc_security_group_ids = [aws_security_group.rds.id]
db_subnet_group_name = aws_db_subnet_group.default.name
publicly_accessible = false
multi_az = false
tags = { Name = "${var.project}-rds" }
}
