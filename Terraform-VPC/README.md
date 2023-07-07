# VPC Terraform Project

This Terraform project creates a VPC on AWS.

## Prerequisites

- Terraform installed (version 1.5.2)
- AWS account with appropriate credentials

## Getting Started

![VPC-terraform](https://github.com/saisamala/Terraform-AWS-Projects/assets/34151152/c16054b0-f99e-4317-8ad5-31697c8e9f96)

Follow these steps to create the VPC:

1. Clone or download this repository.
2. Update the `main.tf` file with your desired configuration.
3. Run `terraform init` to initialize the project.
4. Run `terraform plan` to see the execution plan.
5. Run `terraform apply` to create the VPC.
6. Verify that the VPC has been created in your AWS account.

## Configuration

You can customize the VPC configuration by modifying the `main.tf` file.

- `region`: The AWS region where the VPC will be created.
- `cidr_block`: The CIDR block for the VPC.
- ...

## Cleanup

To destroy the VPC and remove all associated resources, run the following command:
- `terraform destroy`
