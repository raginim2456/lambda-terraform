# Lambda + Terraform Setup

This repo deploys an AWS Lambda function triggered automatically by S3 events (object creation) using Terraform.

## Structure
- `terraform/` — Terraform scripts to deploy Lambda and S3 event notification.
- `lambda/` — Python Lambda function code.

## How to Deploy

```bash
# 1. Zip the Lambda code
cd lambda
zip S3EventLogger.zip lambda_function.py

# 2. Initialize and apply Terraform
cd ../terraform
terraform init
terraform plan
terraform apply
