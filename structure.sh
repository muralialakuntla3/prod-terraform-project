#!/bin/bash

# Define project root
ROOT_DIR="terraform-vpc-project"

# Create directories
mkdir -p $ROOT_DIR/.github/workflows
mkdir -p $ROOT_DIR/.github/actions/setup-terraform
mkdir -p $ROOT_DIR/modules/vpc
mkdir -p $ROOT_DIR/envs/dev
mkdir -p $ROOT_DIR/envs/qa
mkdir -p $ROOT_DIR/envs/prod

# Create empty files
touch $ROOT_DIR/.github/workflows/ci-cd.yml
touch $ROOT_DIR/.github/workflows/deploy.yml
touch $ROOT_DIR/.github/actions/setup-terraform/action.yml

touch $ROOT_DIR/modules/vpc/main.tf
touch $ROOT_DIR/modules/vpc/outputs.tf
touch $ROOT_DIR/modules/vpc/variables.tf

touch $ROOT_DIR/envs/dev/terragrunt.hcl
touch $ROOT_DIR/envs/qa/terragrunt.hcl
touch $ROOT_DIR/envs/prod/terragrunt.hcl

touch $ROOT_DIR/terragrunt.hcl
touch $ROOT_DIR/README.md

echo "Terraform VPC project structure created at ./$ROOT_DIR"

