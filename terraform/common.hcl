locals {
  region         = "us-east-1"
  bucket         = "rmc-digital-ops"
  key            = "terraform/${path_relative_to_include()}.tfstate"
  dynamodb_table = "terraform_locks"
}

inputs = {
  scripts_dir = "${get_parent_terragrunt_dir()}/scripts"
}

remote_state {
  backend = "s3"

  config = {
    bucket         = local.bucket
    region         = local.region
    key            = local.key
    dynamodb_table = local.dynamodb_table
    encrypt        = true
  }
}
