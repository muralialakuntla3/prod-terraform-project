terraform {
  backend "s3" {}
}

resource "aws_vpc" "my-vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.name
  }
}
