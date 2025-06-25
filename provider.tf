terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {}  # <-- REQUIRED placeholder for Terragrunt's remote_state to inject config
}

provider "aws" {
  region = us-west-1  # Or hardcode a default if you prefer
}
