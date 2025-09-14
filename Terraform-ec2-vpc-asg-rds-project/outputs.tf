output "alb_dns_name" {
description = "ALB DNS name"
value = aws_lb.alb.dns_name
}


output "rds_endpoint" {
description = "RDS endpoint"
value = aws_db_instance.mysql.address
}


output "vpc_id" {
value = aws_vpc.this.id
}
