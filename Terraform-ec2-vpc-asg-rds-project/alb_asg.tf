# ALB
resource "aws_lb" "alb" {
name = "${var.project}-alb"
internal = false
load_balancer_type = "application"
subnets = values(aws_subnet.public)[*].id
security_groups = [aws_security_group.alb.id]
tags = { Name = "${var.project}-alb" }
}


resource "aws_lb_target_group" "tg" {
name = "${var.project}-tg"
port = 80
protocol = "HTTP"
vpc_id = aws_vpc.this.id
health_check {
path = "/"
matcher = "200-399"
interval = 30
}
}


resource "aws_lb_listener" "http" {
load_balancer_arn = aws_lb.alb.arn
port = "80"
protocol = "HTTP"


default_action {
type = "forward"
target_group_arn = aws_lb_target_group.tg.arn
}
}


# IAM role for EC2 to allow SSM (optional)
resource "aws_iam_role" "ec2_role" {
name = "${var.project}-ec2-role"
assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}


data "aws_iam_policy_document" "ec2_assume_role" {
statement {
actions = ["sts:AssumeRole"]
principals {
type = "Service"
identifiers = ["ec2.amazonaws.com"]
}
}
}


resource "aws_iam_role_policy_attachment" "ssm_attach" {
role = aws_iam_role.ec2_role.name
policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "ec2_profile" {
name = "${var.project}-ec2-profile"
role = aws_iam_role.ec2_role.name
}


# Launch Template
resource "aws_launch_template" "web_lt" {
name_prefix = "${var.project}-lt-"
image_id = data.aws_ami.ubuntu.id
instance_type = var.instance_type


iam_instance_profile {
name = aws_iam_instance_profile.ec2_profile.name
}


key_name = var.key_name != "" ? var.key_name : null


vpc_security_group_ids = [aws_security_group.app.id]


user_data = base64encode(file("${path.module}/userdata.sh"))


tag_specifications {
resource_type = "instance"
tags = { Name = "${var.project}-web" }
}
}


data "aws_ami" "ubuntu" {
most_recent = true
owners = ["099720109477"] # Canonical
filter {
name = "name"
values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
}
}


# AutoScaling Group that registers with ALB target group
resource "aws_autoscaling_group" "asg" {
name = "${var.project}-asg"
max_size = var.asg_max_size
min_size = var.asg_min_size
desired_capacity = var.asg_desired_capacity
health_check_type = "ELB"
health_check_grace_period = 120


vpc_zone_identifier = values(aws_subnet.private)[*].id


launch_template {
id = aws_launch_template.web_lt.id
version = "$Latest"
}


target_group_arns = [aws_lb_target_group.tg.arn]


tag {
key = "Name"
value = "${var.project}-web"
propagate_at_launch = true
}
}
 
