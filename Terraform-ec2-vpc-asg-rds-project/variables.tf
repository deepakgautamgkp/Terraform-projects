variable "region" {
  description = "AWS region"
  type = string
  default = "ap-south-1"
}

variable "project" {
  description = "project name prefix"
  type = string
  default = "tf-demo"
}

variable "vpc-cidr" {
  default = "10.0.0.0/16"
}

variable "public-subnet-cidr" {
  type = list(string)
  default = [ "10.0.1.0/24", "10.0.2.0/24"]
}

variable "private-subnet-cidr" {
  type = list(string)
  default = [ "10.0.11.0/24", "10.0.12.0/24" ]
}

variable "key_name" {
description = "Existing EC2 key pair name for SSH access (optional)"
type = string
default = ""
}

variable "instance_type" { default = "t3.micro" }
variable "asg_desired_capacity" { default = 2 }
variable "asg_min_size" { default = 1 }
variable "asg_max_size" { default = 3 }
variable "db_username" { default = "tfuser" }
variable "db_password" {
description = "RDS master password (for demo keep short-lived or use secrets manager)
Use terraform.tfvars or environment variable to set securely."
type = string
default = "ChangeMe123!"
}


variable "db_allocated_storage" { default = 20 }
variable "db_instance_class" { default = "db.t3.micro" }
