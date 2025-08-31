terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.66.0"   # latest stable at time of writing
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}
