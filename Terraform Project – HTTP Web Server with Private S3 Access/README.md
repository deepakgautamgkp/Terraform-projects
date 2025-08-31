Project Overview
This Terraform project provisions an AWS infrastructure that hosts a simple HTTP web server in a public EC2 instance, while securely accessing an Amazon S3 bucket through a private EC2 instance within a VPC.

The architecture demonstrates:

A public subnet hosting a web server accessible via the internet.
A private subnet with an EC2 instance that has no direct internet access but can securely access an S3 bucket using a VPC Endpoint.
IAM roles and policies to enable controlled access to the S3 bucket.

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Architecture

VPC with public and private subnets across availability zones.
Public EC2 instance running an HTTP web server (Apache/Nginx).
Private EC2 instance configured to access S3 bucket data.
VPC Endpoint (Gateway) for S3 to allow private communication.
Security Groups to control inbound/outbound traffic.
IAM Role & Instance Profile attached to the private EC2 for S3 bucket access.
terraform-project/
├── main.tf              # Main Terraform configuration  
├── variables.tf         # Input variables  
├── outputs.tf           # Outputs after deployment  
├── provider.tf          # AWS provider configuration  
├── security-group.tf    # Security group definitions  
├── ec2.tf               # Public and private EC2 instances   
├── vpc.tf               # VPC, subnets, route tables, and endpoints  
└── README.md            # Project documentation 



Deployment Steps
-> Initialize Terraform
-----> terraform init
-> Preview the changes
-----> terraform plan
-> Apply the configuration
-----> terraform apply


The private instance has no direct internet access.
Access to S3 is restricted via IAM role + VPC endpoint (no public internet).
Security groups follow the principle of least privilege.
















