![image](https://github.com/user-attachments/assets/af416074-7437-497a-968e-b0efc6ee4ae2)
# AWS ECS RDS Infrastructure

This repository contains Terraform configurations for deploying a containerized application on AWS ECS with RDS backend.

## Structure
- `modules/`: Reusable Terraform modules
- `environments/`: Environment-specific configurations
- `versions.tf`: Provider and Terraform version requirements

## Usage
1. Create s3 bucket for state file (terraform-state-og-1) or choose your own bucket and modify bucket name in main.tf
2. Configure your AWS CLI credentials
3. Navigate to desired environment directory (cd environments/production )
4. Initialize Terraform: `terraform init`
5. Apply configuration: `terraform plan` and `terraform apply`

For quick testing 

cd environments/production 
terraform init
terraform apply -var-file="terraform.tfvars" -lock=false

After applying, it will provide you with the ALB DNS endpoint, by which the application will be accessible publicly.

## Requirements

VPC and Network Components ✅
- Region and AZ of choice ✅
- Subnets (public, private, database) ✅
- Route tables ✅
- Security groups ✅
- NAT gateway ✅
- Internet gateway ✅

Web Application Servers (ECS) ✅
- Running on ECS ✅
- Behind ALB ✅
- No public IPs ✅
- Not directly accessible from internet ✅
- Has internet connectivity (via NAT) ✅

Load Balancer ✅
- Publicly accessible ✅
- In public subnet ✅
- Proper security group ✅

Database ✅
- PostgreSQL 17 ✅
- Separate subnet ✅
- Restricted access from web apps only ✅
