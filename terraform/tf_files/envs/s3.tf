locals {
  buckets_with_access_block  = toset([for k, v in var.s3_buckets : k if v.type != "public"])
  buckets_with_public_policy = toset([for k, v in var.s3_buckets : k if v.type == "public"])
}

resource "aws_s3_bucket" "bucket" {
  for_each = var.s3_buckets

  bucket = each.key
  acl    = each.value.type == "public" ? "public-read" : "private"

  dynamic "cors_rule" {
    for_each = each.value.cors_url != "" ? [each.value.cors_url] : []
    content {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = [each.value.cors_url]
    }
  }

  dynamic "server_side_encryption_configuration" {
    for_each = each.value.encryption ? [each.key] : []
    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
  }

  versioning {
    enabled = each.value.versioning
  }

  tags = local.common_tags
}

resource "aws_s3_bucket_policy" "public_policy" {
  for_each = local.buckets_with_public_policy

  bucket = each.value

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${each.value}/*"
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "access_block" {
  for_each = local.buckets_with_access_block

  bucket = each.value

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
