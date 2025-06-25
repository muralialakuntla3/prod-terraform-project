# 🚀 Terraform Infrastructure Deployment with Terragrunt & GitHub Actions

This project automates provisioning and destruction of AWS infrastructure (custom VPCs) across multiple environments (`dev`, `qa`, `prod`) using:

- **Terraform** modules
- **Terragrunt** for environment configuration and remote state
- **GitHub Actions** for CI/CD pipelines with:
  - `workflow_call`
  - `workflow_dispatch`
  - `composite actions`
  - `concurrency`

---

## 🧱 Project Structure

```
terraform-vpc-project/
├── .github/
│   ├── workflows/
│   │   ├── ci-cd.yml
│   │   ├── deploy.yml
│   │   └── destroy.yml
│   └── actions/
│       └── setup-terraform/
│           └── action.yml
├── modules/
│   └── vpc/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
├── envs/
│   ├── dev/
│   │   └── terragrunt.hcl
│   ├── qa/
│   │   └── terragrunt.hcl
│   └── prod/
│       └── terragrunt.hcl
├── terragrunt.
│── provider.tf
└── README.md
```

---

## 🌍 Terraform VPC Module

### `modules/vpc/main.tf`
```hcl
terraform {
  backend "s3" {}
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.name
  }
}
```

### `variables.tf`
```hcl
variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "name" {
  type        = string
  description = "Name of the VPC"
}
```

### `provider.tf`
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type        = string
  description = "AWS Region to deploy"
}

```

---

## 🌐 Terragrunt Configuration

### `terragrunt.hcl`
```hcl
remote_state {
  backend = "s3"
  config = {
    bucket = "my-terragrunt-backend-bucket"
    key    = "${path_relative_to_include()}/terraform.tfstate"
    region = "us-west-1"
  }
}
```

### `envs/dev/terragrunt.hcl` (Same structure for `qa` and `prod`)
```hcl
include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/vpc"
}

inputs = {
  name       = "dev-vpc"
  cidr_block = "10.0.0.0/16"
  region     = get_env("TF_VAR_REGION", "us-west-1")
}
```

---

## ⚙️ GitHub Actions Setup

### 🔐 GitHub Secrets
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### 🔧 GitHub Variables (optional fallback)
- `AWS_REGION = us-west-1`

---

### `.github/actions/setup-terraform/action.yml`
```yaml
name: Setup Terraform
description: Install Terraform and Terragrunt
runs:
  using: "composite"
  steps:
    - name: Install Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: 1.5.0

    - name: Install Terragrunt
      shell: bash
      run: |
        curl -L -o terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v0.82.0/terragrunt_linux_amd64
        chmod +x terragrunt
        sudo mv terragrunt /usr/local/bin/
```

---

## 🚀 Workflows

### `ci-cd.yml`
```yaml
name: Terraform CI/CD Entry

on:
  workflow_dispatch:
    inputs:
      environment:
        required: true
        type: choice
        options: [dev, qa, prod]

jobs:
  deploy:
    uses: ./.github/workflows/deploy.yml
    with:
      environment: ${{ github.event.inputs.environment }}
    secrets: inherit
```

### `deploy.yml`
```yaml
name: Deploy Terraform Environment

on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string

concurrency:
  group: terraform-${{ inputs.environment }}
  cancel-in-progress: true

jobs:
  terraform:
    runs-on: ubuntu-latest
    defaults:
      run:
        shell: bash
        working-directory: envs/${{ inputs.environment }}
    env:
      AWS_REGION: ${{ vars.AWS_REGION }}
      TF_VAR_REGION: ${{ vars.AWS_REGION }}

    strategy:
      matrix:
        action: [init, plan, apply]

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ vars.AWS_REGION }}  

      - name: Setup Terraform and Terragrunt
        uses: ./.github/actions/setup-terraform

      - name: Terragrunt ${{ matrix.action }}
        run: |
          echo "Running terragrunt ${{ matrix.action }}"
          if [[ "${{ matrix.action }}" == "plan" ]]; then
            terragrunt plan 
          elif [[ "${{ matrix.action }}" == "apply" ]]; then
            terragrunt apply -auto-approve
          else
            terragrunt ${{ matrix.action }}
          fi
```

### `destroy.yml`
```yaml
name: Destroy Terraform Environment

on:
  workflow_dispatch:
    inputs:
      environment:
        description: "Select the environment to destroy"
        required: true
        type: choice
        options: [dev, qa, prod]

concurrency:
  group: destroy-${{ github.event.inputs.environment }}
  cancel-in-progress: true

jobs:
  destroy:
    runs-on: ubuntu-latest
    defaults:
      run:
        shell: bash
        working-directory: envs/${{ github.event.inputs.environment }}
    env:
      AWS_REGION: ${{ vars.AWS_REGION }}
      TF_VAR_REGION: ${{ vars.AWS_REGION }}

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ vars.AWS_REGION }}

      - name: Setup Terraform and Terragrunt
        uses: ./.github/actions/setup-terraform

      - name: Destroy Infrastructure
        run: terragrunt destroy -auto-approve

```

---

## ✅ Summary

| Component       | Tool       | Purpose                                 |
|----------------|------------|-----------------------------------------|
| Infrastructure | Terraform  | Define AWS resources using modules      |
| State Mgmt     | Terragrunt | Manage remote state, inputs per env     |
| Automation     | GitHub Actions | Trigger deploy/destroy on demand     |
| Environments   | dev, qa, prod | Isolated infra with same code         |
| Security       | GitHub Secrets | Store AWS creds safely               |
