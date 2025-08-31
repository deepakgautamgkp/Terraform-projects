
/*
-------------------------------------- public Instances -----------------------------------------------------------
*/
resource "aws_instance" "public-web-server" {
  ami           = var.ami
  instance_type = var.instance_type
  count = length(var.public_subnet_cidr)
  availability_zone = data.aws_availability_zones.AZ.names[count.index]
  security_groups = [aws_security_group.public_subnet_sg.id]
  subnet_id = aws_subnet.public-subnet[count.index].id
  key_name = aws_key_pair.my_ec2_key.key_name
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "<h1> Hello this is the webserver from $(hostname -f)</h1>" > /var/www/html/index.html
              EOF
  
  tags = {
    Name = "${local.enviroment_var}-public-Instance"
  }
}

/*
-------------------------------------------- private subnet -----------------------------------
*/
resource "aws_instance" "private-web-server" {
  ami              = var.ami
  instance_type    = var.instance_type
  availability_zone = data.aws_availability_zones.AZ.names[0]
  security_groups = [aws_security_group.private-subnet-sg.id]
  subnet_id       = aws_subnet.Private_subnet[0].id
  key_name = aws_key_pair.my_ec2_key.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = false
  user_data = <<-EOF
              #!/bin/bash
              sudo yum install -y awscli
              sudo echo "Testing S3 access..." > /tmp/test.txt
              sudo aws s3 cp /tmp/test.txt s3://${aws_s3_bucket.mybucket.bucket}/
              EOF
  
  
  tags = {
    Name = "${local.enviroment_var}-private-instance"
  }
}
