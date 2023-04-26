resource "random_string" "rds_suffix" {
  for_each = { for k, v in var.rds_instances : k => v if v.add_identifier_suffix }

  length      = 8
  min_numeric = 2
  min_lower   = 2
  lower       = true
  upper       = false
  special     = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_string" "source_snapshot_suffix" {
  for_each = { for k, v in var.rds_instances : k => v if length(v.snapshot_source_instance) > 0 }

  length      = 8
  min_numeric = 2
  min_lower   = 2
  lower       = true
  upper       = false
  special     = false

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  rds_identifier = {
    for k, v in var.rds_instances :
    k => v.add_identifier_suffix ? "${k}-${random_string.rds_suffix[k].result}" : k
  }
  rds_encrypted = {
    for k, v in var.rds_instances :
    k => v if v.encrypt_storage
  }
  source_snapshot_identifier = {
    for k, v in var.rds_instances :
    k => length(v.snapshot_source_instance) > 0 ? "${v.snapshot_source_instance}-sync-snapshot-${random_string.source_snapshot_suffix[k].result}" : (length(v.snapshot_identifier) > 0 ? v.snapshot_identifier : "")
  }
}

resource "aws_kms_key" "rds_encryption_key" {
  count = length(local.rds_encrypted) > 0 ? 1 : 0

  description = "${var.project_name}@${var.project_env} RDS Encryption Key"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow access through RDS for all principals in the account that are authorized to use RDS",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:DescribeKey"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:CallerAccount": "${data.aws_caller_identity.current.account_id}",
                    "kms:ViaService": "rds.${data.aws_region.current.name}.amazonaws.com"
                }
            }
        },
        {
            "Sid": "Allow direct access to key metadata to the account",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": [
                "kms:Describe*",
                "kms:Get*",
                "kms:List*",
                "kms:RevokeGrant"
            ],
            "Resource": "*"
        }
    ]
}
POLICY

  tags = merge({
    "Name" = "${var.project_name}@${var.project_env} RDS Encryption Key"
  }, local.common_tags)
}

resource "aws_kms_alias" "rds_encryption_key_alias" {
  count = length(local.rds_encrypted) > 0 ? 1 : 0

  name          = "alias/${var.project_name}-${var.project_env}_rds-encryption-key"
  target_key_id = aws_kms_key.rds_encryption_key[0].key_id
}

resource "aws_db_snapshot" "source_rds_snapshot" {
  for_each               = { for k, v in local.source_snapshot_identifier : k => v if length(var.rds_instances[k].snapshot_source_instance) > 0 }
  db_instance_identifier = var.rds_instances[each.key].snapshot_source_instance
  db_snapshot_identifier = each.value

  tags = local.common_tags
}

resource "aws_db_instance" "main" {
  for_each = var.rds_instances

  identifier                      = local.rds_identifier[each.key]
  allocated_storage               = each.value["allocated_storage"]
  max_allocated_storage           = each.value["max_allocated_storage"]
  storage_encrypted               = each.value["encrypt_storage"]
  kms_key_id                      = each.value["encrypt_storage"] ? aws_kms_key.rds_encryption_key[0].arn : null
  storage_type                    = "gp2"
  engine                          = each.value["engine"]
  engine_version                  = each.value["engine_version"]
  instance_class                  = each.value["instance_class"]
  name                            = each.value["database_name"]
  username                        = each.value["master_username"]
  password                        = each.value["master_password"]
  snapshot_identifier             = local.source_snapshot_identifier[each.key]
  db_subnet_group_name            = aws_db_subnet_group.main.id
  publicly_accessible             = each.value["public_access"]
  vpc_security_group_ids          = [aws_security_group.rds.id]
  skip_final_snapshot             = each.value["skip_final_snapshot"]
  final_snapshot_identifier       = "${local.rds_identifier[each.key]}-final"
  deletion_protection             = each.value["deletion_protection"]
  backup_retention_period         = each.value["backup_retention_period"]
  multi_az                        = each.value["multi_az"]
  enabled_cloudwatch_logs_exports = each.value["cloudwatch_logs"]

  tags = merge({
    "Name" = local.rds_identifier[each.key]
  }, local.common_tags)

  lifecycle {
    ignore_changes        = [snapshot_identifier, password]
    create_before_destroy = true
  }

  depends_on = [
    aws_db_snapshot.source_rds_snapshot
  ]
}

resource "aws_route53_record" "rds_cname" {
  for_each = { for k, v in var.rds_instances : k => v if length(v.custom_cname) > 0 }

  zone_id = aws_route53_zone.primary[each.value.custom_cname_zone].zone_id
  name    = each.value.custom_cname
  type    = "CNAME"
  ttl     = "60"
  records = [aws_db_instance.main[each.key].address]
}
