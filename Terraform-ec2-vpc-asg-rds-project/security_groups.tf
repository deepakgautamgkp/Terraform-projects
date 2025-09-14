# ALB SG: allow HTTP from internet
resource "aws_security_group" "alb" {
name = "${var.project}-alb-sg"
vpc_id = aws_vpc.main-vpc.id


ingress {
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
egress { 
    from_port = 0
    to_port = 0
    protocol = "-1"
     cidr_blocks = ["0.0.0.0/0"] 
}
}

# App SG: allow from ALB and SSH from your IP if provided
resource "aws_security_group" "app" {
name = "${var.project}-app-sg"
vpc_id = aws_vpc.main-vpc.id


ingress {
from_port = 80
to_port = 80
protocol = "tcp"
security_groups = [aws_security_group.alb.id]
}


dynamic "ingress" {
for_each = var.key_name != "" ? [1] : []
content {
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"] # replace with your IP for security
}
}


egress { 
    from_port = 0
     to_port = 0
     protocol = "-1"
     cidr_blocks = ["0.0.0.0/0"] 
     }
}


# RDS SG: allow MySQL from app servers only
resource "aws_security_group" "rds" {
name = "${var.project}-rds-sg"
vpc_id = aws_vpc.this.id


ingress {
from_port = 3306
to_port = 3306
protocol = "tcp"
security_groups = [aws_security_group.app.id]
}
egress { 
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
    }
}

