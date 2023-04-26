terraform {
  backend "s3" {}
  required_version = ">= 1.1"
  required_providers {
    aws = "~> 4.46.0"
    postgresql = { 
      source = "cyrilgdn/postgresql"
      version = "1.15.0"
    }
  }

}

provider "aws" {
  region  = var.aws_region
  assume_role {
    # The role ARN within the chosen digital AWS account to AssumeRole into. 
    role_arn    = "arn:aws:iam::${var.aws_account}:role/${local.stack_name}-terraform-role"
  }
}

### AWS EKS Provider Alias
### Kubernetes uses this provider with eks_master_user_role assumption to generate a valid token for cluster API access. 
###This role is included in cluster config mapping.
provider "aws" {
  region  = "us-east-1"
  alias   = "aws-eks"
  assume_role {
    role_arn    = aws_iam_role.eks_master_user_role.arn
  }
}
