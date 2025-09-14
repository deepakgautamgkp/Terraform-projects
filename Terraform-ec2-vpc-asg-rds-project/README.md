Terraform project: EC2 + VPC + ALB (Load Balancer) + Auto Scaling Group + RDS


This repository contains a ready-to-run Terraform project that deploys:


- VPC (public + private subnets) with IGW and NAT Gateway
- Security Groups for bastion/frontend/backend/RDS
- Application Load Balancer (ALB) for HTTP
- Launch Template + Auto Scaling Group (ASG) for EC2 web servers attached to ALB Target Group
- RDS (MySQL) in private subnets with subnet group and security group

- ## Repo layout (single-file representation)


```
├── README.md              # this file (instructions)
├── providers.tf           # provider & terraform settings
├── vpc.tf                 # VPC, subnets, IGW, route tables, nat gateway
├── security_groups.tf     # security groups
├── alb_asg.tf             # ALB, target group, listener, launch template, autoscaling group
├── rds.tf                 # RDS instance and subnet group
├── userdata.sh            # simple user data for EC2 (install nginx and healthcheck)
├── variables.tf           # variables with defaults
├── terraform.tfvars.example # example values for required variables
├── outputs.tf           # useful outputs


Prerequisites


- Terraform 1.3+
- AWS credentials configured in environment or via AWS CLI
- An existing EC2 keypair if you want SSH access (optional)


## Quick start


1. Save files shown in this repo structure into a directory.
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and set values.
3. Run:


```bash
terraform init
terraform plan -out plan.out
terraform apply "plan.out"
```


4. After apply completes, get the ALB DNS from outputs and open it in a browser.
