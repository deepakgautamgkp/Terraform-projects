
#  Graph 
 https://is.gd/meQjHN


## Project Overview
This project provisions AWS infrastructure using **Terraform**.  
It includes:
- A **VPC** with public and private subnets
- **Security Groups** for controlled access
- An **EC2 instance** running in the VPC
- An **Application Load Balancer (ALB)** to distribute traffic

## Prerequisites
Before you begin, make sure you have:
- [Terraform](https://developer.hashicorp.com/terraform/downloads) installed
- [AWS CLI](https://docs.aws.amazon.com/cli/) configured with credentials
- An AWS account with appropriate permissions

## 🚀 Deployment Steps
1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/terraform-aws-project.git
   cd terraform-aws-project

Initialize Terraform:
 # terraform init

Review the execution plan:
 # terraform plan

Apply the configuration:
 # terraform apply -auto-approve

After apply, Terraform will output the Load Balancer DNS name.
Access it in your browser to verify the setup.
