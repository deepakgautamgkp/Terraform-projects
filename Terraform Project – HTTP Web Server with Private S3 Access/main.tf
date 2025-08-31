locals {
  enviroment_var = "Dev"
}
data "aws_availability_zones" "AZ" {
  state = "available"
}
/*
---------------------------------------------------------------------- creating a Key pair to access the Ec2 instance --------------------------------------------------------------------------------------------------------
*/
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "my_ec2_key" {
  key_name   = "my-terraform-key"
  public_key = tls_private_key.my_key.public_key_openssh
}

resource "local_file" "private_key" {
  content          = tls_private_key.my_key.private_key_pem
  filename         = "${path.module}/my-terraform-key.pem"
  file_permission  = "0600"
}

/*
-------------------------------------- Creating IAM Role for EC2 to access s3 buckets -----------------------------------------------------
*/

resource "aws_s3_bucket" "mybucket" {
  bucket = "my-private-ec2-s3-bucket-demo"
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}



resource "aws_iam_role_policy" "s3_access" {
  name = "ec2-s3-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Statement1",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject"
      ],
      "Resource": "*"
    }
  ]
  })
}


resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}




















