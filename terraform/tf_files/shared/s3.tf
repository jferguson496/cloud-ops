## Ops bucket
resource "aws_s3_bucket" "ops" {
  bucket = var.s3_ops_bucket
  acl    = "private"

  dynamic server_side_encryption_configuration {
    for_each = var.s3_ops_aes_encryption ? [0] : []
    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
  }

  versioning {
    enabled = true
  }

  tags = {
    env         = "shared"
    provisioner = "terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "ops" {
  bucket = aws_s3_bucket.ops.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
