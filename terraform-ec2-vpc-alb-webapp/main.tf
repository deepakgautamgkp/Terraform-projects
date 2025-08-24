
/*
-------------------------------------------- VPC ------------------------------------------
*/

resource "aws_vpc" "main-vpc" {
  cidr_block = var.vpc-cidr
}

# creating subnets 
resource "aws_subnet" "public-subnet" {
  for_each = local.subnets.public-sub
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = each.value
  availability_zone = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

/*
resource "aws_subnet" "private-subnet" {
  for_each = local.subnets.private-sub
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = each.value
  availability_zone = local.azs[1]
  tags = {
    Name = "private-subnet"
  }
}
*/
# creating IGW 

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "igw"
  }
}

# creating Route tables 
resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route"
  }
}

resource "aws_route_table_association" "public-associ" {
   for_each       = aws_subnet.public-subnet
   subnet_id      = each.value.id
  # subnet_id      = values(aws_subnet.public-subnet)[0].id                             if you wants a single id 
  route_table_id  = aws_route_table.public-route.id

}


/* # private route table
resource "aws_route_table" "private-route" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "private-route"
  }
}
resource "aws_route_table_association" "private-associ" {
  for_each       = aws_subnet.private-subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private-route.id
}

*/

/*
----------------------------------- Security Group -------------------------------------------------------------------------------
*/
resource "aws_security_group" "web-server-sg" {
  name        = "web-server-sg"
  description = "allow all request form anywhere "
  vpc_id      = aws_vpc.main-vpc.id
  dynamic "ingress" {
    for_each = var.ingress_rule
    content {
      from_port = ingress.value.from_port
      to_port = ingress.value.to_port
      protocol = ingress.value.protocol
      description = ingress.value.description
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_tls"
  }
}


/*
----------------------------------------- Ec2 Instances ----------------------------------------------------------------------------
*/
resource "aws_instance" "web-server" {
  for_each     = aws_subnet.public-subnet
  ami                   = var.ami
  instance_type         = var.instance_type
  vpc_security_group_ids = [aws_security_group.web-server-sg.id]
  subnet_id             = each.value.id
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd

              echo "<h1> Hello this is the webserver from $(hostname -f)</h1>" > /var/www/html/index.html

              EOF
  tags = {
    Name = "my-web-server"
  }
}

/*
---------------------------------------- Load Balancer --------------------------------------------------------------------------------------
*/

resource "aws_lb" "application_load_balancer" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-server-sg.id]
  subnets            = [for subnet in aws_subnet.public-subnet : subnet.id]

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

# target groups
resource "aws_lb_target_group" "target_group" {
  name     = "tf-example"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main-vpc.id
  ip_address_type = "ipv4"
   target_type = "instance"
  

  # Health check configuration
   health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
   }

}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# Register EC2 Instances with the Target Group
resource "aws_lb_target_group_attachment" "app_tg_attachment" {
    for_each = aws_instance.web-server
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = each.value.id   # Replace with your instance id
  port             = 80
}
