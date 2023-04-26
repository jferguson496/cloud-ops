#
# Common variables
#
variable "aws_profile" {
  description = "The AWS CLI profile (as seen in ~/.aws/config)"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy to (e.g. us-east-1)"
  type        = string
}

variable "scripts_dir" {
  type = string
}

locals {
  common_tags = {
    env         = "shared",
    provisioner = "terraform",
  }
}

#
# VPC
#
variable "vpc_public_cidr_block" {
  type = string
}

variable "vpc_public_subnet_newbits" {
  type = number
}

variable "vpc_private_cidr_block" {
  type = string
}

variable "vpc_private_subnet_newbits" {
  type = number
}

variable "vpc_subnet_count" {
  type = number
}

#
# VPN
#
variable "vpn_connections" {
  type    = any
  default = {}
}

#
# S3
#
variable "s3_ops_bucket" {
  description = "S3 bucket that holds tf states, keys, etc"
  type        = string
}

variable "s3_ops_aes_encryption" {
  description = "Wether to encrypt the ops bucket with AES256"
  type        = bool
  default     = false
}

#
# ECR
#
variable "ecr_repositories" {
  description = "List of repositories to create"
  type        = set(string)
}

variable "ecr_external_access" {
  description = "AWS entities allowed to read from this repository"
  type        = list(string)
}

variable "ecr_image_scanning" {
  description = "Wether to scan images on push"
  type        = bool
}

variable "ecr_tag_mutability" {
  description = "Can the image tags be changed / replaced"
  type        = bool
}

variable "ecr_image_timeout" {
  description = "After how many days should images be deleted."
  type        = number
}

variable "ecr_dev_image_tag_prefix" {
  description = "Dev image tag prefix. Ie. dev matches nginx:dev-alpine"
  type        = string
}

variable "ecr_dev_image_timeout" {
  description = "After how many days should dev images be deleted."
  type        = number
}

#
# GHA Runner
#
variable "gha_runner_count" {
  type = number
}

variable "gha_runner_instance_type" {
  type = string
}

variable "gha_runner_volume_size" {
  type = number
}

variable "gha_runner_volume_type" {
  type = string
}

variable "gha_runner_volume_throughput" {
  type    = number
  default = null
}

variable "gha_runner_volume_iops" {
  type    = number
  default = null
}

variable "gha_runner_agent_archive" {
  type = string
}

variable "gha_runner_agent_archive_hash" {
  type = string
}

variable "gha_runner_agent_name_prefix" {
  type = string
}

variable "gha_runner_agent_url" {
  type = string
}

variable "gha_runner_agent_token" {
  type = string
}

variable "gha_runner_ssm_enabled" {
  type = bool
}

variable "gha_runner_ssh_master_key" {
  type    = string
  default = ""
}

variable "gha_runner_extra_labels" {
  type    = string
  default = ""
}

#
# Route53
#
variable "r53_zones" {
  type    = any
  default = {}
}

#
# Twilio callback proxy
#
variable "twilio_proxy_r53_zone" {
  type = string
}

variable "twilio_proxy_r53_domain" {
  type = string
}

variable "twilio_proxy_caddy_version" {
  type = string
}
