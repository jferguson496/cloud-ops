variable "aws_profile" {
  description = "The AWS CLI profile (as seen in ~/.aws/config)"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy to (e.g. us-east-1)"
  type        = string
}

variable "aws_account" {
  description = "The AWS account number to deploy to "
  type        = string
}

variable "scripts_dir" {
  type = string
}

variable "project_name" {
  description = "Name of the project. It will be used for naming resources"
  type        = string
}

variable "project_env" {
  description = "The stacks environment name"
  type        = string
}

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

locals {
  stack_name = "${var.project_name}-${var.project_env}"
  common_tags = {
    project     = var.project_name,
    env         = var.project_env,
    provisioner = "terraform",
  }
}

variable "eks_kubernetes_version" {
  type = string
}

variable "eks_master_private_api_access" {
  type = bool
}

variable "eks_master_public_api_access" {
  type = bool
}

variable "eks_master_public_access_cidrs" {
  type = list(string)
}

variable "eks_master_authorize_gha_runner" {
  type = bool
}

variable "eks_master_gha_runner_role" {
  type = string
}

variable "eks_master_enabled_log_types" {
  type    = list(string)
  default = []
}

variable "eks_master_log_retention" {
  type    = number
  default = 90
}

variable "eks_worker_instance_type" {
  type = string
}

#Green ASG
variable "eks_worker_green_ami_version" {
  type    = string
}
variable "eks_worker_green_asg_min_size" {
  type = number
}
variable "eks_worker_green_asg_max_size" {
  type = number
}
variable "eks_kubernetes_version_green" {
  type = string
}

#Blue ASG
variable "eks_worker_blue_ami_version" {
  type    = string
}
variable "eks_worker_blue_asg_min_size" {
  type = number
}
variable "eks_worker_blue_asg_max_size" {
  type = number
}
variable "eks_kubernetes_version_blue" {
  type = string
}

variable "eks_worker_asg_metrics" {
  type = bool
}

variable "eks_worker_ssh_master_key" {
  type = string
}

variable "eks_worker_ssh_additional_keys" {
  type = list(string)
}

variable "eks_worker_ssh_access" {
  type = bool
}

variable "eks_worker_ssh_cidr_whitelist" {
  description = "IPs allowed to SSH into the instance. A map of cidr = description."
  type        = map(string)
}

variable "eks_worker_ssm_access" {
  type = bool
}

variable "eks_worker_ssm_rpm" {
  type = string
}

variable "eks_worker_asg_volume_size" {
  type = number
}

variable "eks_worker_asg_volume_type" {
  type = string
}

variable "eks_worker_kubelet_extra_flags" {
  type = string
}

variable "eks_worker_request_spot_instances" {
  type = bool
}

variable "eks_worker_asg_attach_alb_target_groups" {
  type    = list(string)
  default = []
}

#
# VPN
#
variable "vpn_connections" {
  type    = any
  default = {}
}

#
# LB
#
variable "lb_instances" {
  type    = any
  default = {}
}

#
# Route53
#
variable "r53_zones" {
  description = "Route53 zones to create"
  type        = set(string)
  default     = []
}

variable "r53_caa_records" {
  description = "Route53 CAA records to create"
  type        = list(string)
  default     = []
}

#
# ACM
#
variable "acm_certificates" {
  type = map(object({
    san      = list(string)
    r53_zone = string
  }))
  default = {}
}

#
# RDS
#
variable "rds_instances" {
  type = map(object({
    add_identifier_suffix    = bool
    engine                   = string
    engine_version           = string
    instance_class           = string
    allocated_storage        = number
    max_allocated_storage    = number
    encrypt_storage          = bool
    database_name            = string
    master_username          = string
    master_password          = string
    snapshot_source_instance = string
    snapshot_identifier      = string
    skip_final_snapshot      = bool
    backup_retention_period  = number
    deletion_protection      = bool
    public_access            = bool
    custom_cname             = string
    custom_cname_zone        = string
    multi_az                 = bool
    cloudwatch_logs          = list(string)
    vpn_subnet_access        = list(object({
      description            = string
      source                 = list(string)
    }))
    # additional_access        = list(object({
    #   description            = string
    #   source                 = list(string)
    # }))
  }))
  default = {}
}

#
# ElastiCache
#
variable "elasticache_instances" {
  type = map(object({
    engine         = string
    engine_version = string
    instance_class = string
  }))
  default = {}
}

#
# IAM
#
variable "iam_application_roles" {
  type = map(object({
    bucket_rw_access = list(string)
    bucket_ro_access = list(string)
    secrets_access   = list(string)
    ses_access       = list(string)
  }))
}

variable "s3_buckets" {
  type = map(object({
    type       = string
    cors_url   = string
    versioning = bool
    encryption = bool
  }))
  default = {}
}

variable "secrets_manager_init" {
  type = set(string)
}
