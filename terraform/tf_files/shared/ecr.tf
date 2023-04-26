resource "aws_ecr_repository" "main" {
  for_each = var.ecr_repositories

  name                 = each.key
  image_tag_mutability = var.ecr_tag_mutability ? "MUTABLE" : "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = var.ecr_image_scanning
  }

  tags = {
    env         = "shared"
    provisioner = "terraform"
  }
}

data "aws_iam_policy_document" "ecr_external_access_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeImageScanFindings",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:ListTagsForResource",
    ]
    principals {
      type        = "AWS"
      identifiers = var.ecr_external_access
    }
  }
}

resource "aws_ecr_repository_policy" "external_access" {
  for_each = aws_ecr_repository.main

  repository = each.key

  policy = data.aws_iam_policy_document.ecr_external_access_policy.json
}

resource "aws_ecr_lifecycle_policy" "remove_stale" {
  for_each = aws_ecr_repository.main

  repository = each.key

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire dev images older than ${var.ecr_dev_image_timeout} days",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["${var.ecr_dev_image_tag_prefix}"],
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": ${var.ecr_dev_image_timeout}
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Expire images older than ${var.ecr_image_timeout} days",
      "selection": {
        "tagStatus": "any",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": ${var.ecr_image_timeout}
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}
