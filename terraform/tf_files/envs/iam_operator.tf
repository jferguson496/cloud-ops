##
## Cluster Autoscaler Role
##
resource "aws_iam_role" "cluster-autoscaler-role" {
  name = "eks-service_${local.stack_name}_cluster-autoscaler"

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
        "StringEquals": {
          "${trimprefix(aws_eks_cluster.main.identity.0.oidc.0.issuer, "https://")}:sub": "system:serviceaccount:kube-system:cluster-autoscaler"
        }
      }
    }
  ]
}
POLICY

  tags = merge({
    "Name" = "eks-service_${local.stack_name}_cluster-autoscaler"
  }, local.common_tags)
}

resource "aws_iam_policy" "cluster-autoscaler-policy" {
  name        = "eks_${local.stack_name}_cluster-autoscaler-policy"
  description = "Allow Cluster Autoscaler to manage node ASG"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": [
                "${aws_autoscaling_group.worker_green.arn}",
                "${aws_autoscaling_group.worker_blue.arn}"
            ],
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks-cluster-autoscaler-access" {
  policy_arn = aws_iam_policy.cluster-autoscaler-policy.arn
  role       = aws_iam_role.cluster-autoscaler-role.name
}

##
## external-dns Role
##
resource "aws_iam_role" "external-dns-role" {
  name = "eks-service_${local.stack_name}_external-dns"

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
        "StringEquals": {
          "${trimprefix(aws_eks_cluster.main.identity.0.oidc.0.issuer, "https://")}:sub": "system:serviceaccount:external-dns:external-dns"
        }
      }
    }
  ]
}
POLICY

  tags = merge({
    "Name" = "eks-service_${local.stack_name}_external-dns"
  }, local.common_tags)
}

locals {
  r53_zones_ids = [for zone in var.r53_zones : aws_route53_zone.primary[zone].zone_id]
}

data "aws_iam_policy_document" "external-dns-policy" {
  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]
    resources = formatlist("arn:aws:route53:::hostedzone/%s", local.r53_zones_ids)
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZones"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "external-dns-policy" {
  name        = "eks_${local.stack_name}_external-dns-policy"
  description = "Allow external-dns to manage Route53 domains."

  policy = data.aws_iam_policy_document.external-dns-policy.json
}

resource "aws_iam_role_policy_attachment" "eks-external-dns-access" {
  policy_arn = aws_iam_policy.external-dns-policy.arn
  role       = aws_iam_role.external-dns-role.name
}

##
## fluentd Role
##
resource "aws_iam_role" "fluentd-role" {
  name = "eks-service_${local.stack_name}_fluentd"

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
        "StringEquals": {
          "${trimprefix(aws_eks_cluster.main.identity.0.oidc.0.issuer, "https://")}:sub": "system:serviceaccount:fluentd:fluentd"
        }
      }
    }
  ]
}
POLICY

  tags = merge({
    "Name" = "eks-service_${local.stack_name}_fluentd"
  }, local.common_tags)
}

resource "aws_iam_policy" "fluentd-policy" {
  name        = "eks_${local.stack_name}_fluentd-policy"
  description = "Allow fluentd to create log groups and push logs."

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "ec2:DescribeVolumes",
                "ec2:DescribeTags",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:CreateLogStream",
                "logs:CreateLogGroup",
                "logs:PutRetentionPolicy"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks-fluentd-access" {
  policy_arn = aws_iam_policy.fluentd-policy.arn
  role       = aws_iam_role.fluentd-role.name
}
