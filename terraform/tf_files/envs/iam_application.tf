resource "aws_iam_role" "application_role" {
  for_each = var.iam_application_roles

  name = "eks-service_${local.stack_name}_${each.key}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${trimprefix(aws_eks_cluster.main.identity.0.oidc.0.issuer, "https://")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "${trimprefix(aws_eks_cluster.main.identity.0.oidc.0.issuer, "https://")}:sub": "system:serviceaccount:*:${each.key}"
        }
      }
    }
  ]
}
POLICY

  tags = merge({
    "Name" = "eks-service_${local.stack_name}_${each.key}"
  }, local.common_tags)
}

data "aws_iam_policy_document" "application_role_policy_document" {
  for_each = var.iam_application_roles

  ## bucket_rw_access permissions
  dynamic "statement" {
    for_each = length(each.value.bucket_rw_access) > 0 ? [""] : []
    content {
      actions   = ["s3:ListBucket"]
      resources = formatlist("arn:aws:s3:::%s", each.value.bucket_rw_access)
    }
  }

  dynamic "statement" {
    for_each = length(each.value.bucket_rw_access) > 0 ? [""] : []
    content {
      actions = [
        "s3:*Object",
        "s3:*ObjectAcl"
      ]
      resources = formatlist("arn:aws:s3:::%s/*", each.value.bucket_rw_access)
    }
  }

  ## bucket_ro_access permissions
  dynamic "statement" {
    for_each = length(each.value.bucket_ro_access) > 0 ? [""] : []
    content {
      actions   = ["s3:ListBucket"]
      resources = formatlist("arn:aws:s3:::%s", each.value.bucket_ro_access)
    }
  }

  dynamic "statement" {
    for_each = length(each.value.bucket_ro_access) > 0 ? [""] : []
    content {
      actions = [
        "s3:Get*",
        "s3:List*"
      ]
      resources = formatlist("arn:aws:s3:::%s/*", each.value.bucket_ro_access)
    }
  }

  ## secrets manager permissions
  dynamic "statement" {
    for_each = length(each.value.secrets_access) > 0 ? [""] : []
    content {
      actions = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      resources = formatlist("arn:aws:secretsmanager:*:${data.aws_caller_identity.current.account_id}:secret:%s*", each.value.secrets_access)
    }
  }

  dynamic "statement" {
    for_each = length(each.value.ses_access) > 0 ? [""] : []
    content {
      actions = [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ]
      resources = [
        "*",
      ]
      condition {
        test     = "ForAllValues:StringLike"
        variable = "ses:FromAddress"
        values   = formatlist("*@%s", each.value.ses_access)
      }
    }
  }
}

resource "aws_iam_policy" "application_role_policy" {
  for_each = var.iam_application_roles

  name        = "eks_${local.stack_name}_${each.key}-policy"
  description = "Allow ${each.key} serviceaccount to access AWS resources."

  policy = data.aws_iam_policy_document.application_role_policy_document[each.key].json
}

resource "aws_iam_role_policy_attachment" "application_role_policy_attachment" {
  for_each = var.iam_application_roles

  policy_arn = aws_iam_policy.application_role_policy[each.key].arn
  role       = aws_iam_role.application_role[each.key].name
}
