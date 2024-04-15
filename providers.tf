terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

    backend "s3" {
    bucket = "three-tier-terraform-backend"
      key = "three-tier/terraform.tfstate"
      region = "ca-central-1"
    }
}

provider "aws" {
  region = var.aws_region
}
