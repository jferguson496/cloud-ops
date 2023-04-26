terraform {
  backend "s3" {}
  required_version = ">= 1.1"
  required_providers {
    aws = "~> 3.0"
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}
