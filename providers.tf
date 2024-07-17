terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "PLACE_NAME_OF_BACKEND_S3_BUCKET"
    key    = "PLACE_KEY_NAME_HERE"
    region = "ca-central-1"
  }
}

provider "aws" {
  region = var.aws_region
}
