data "aws_caller_identity" "current" {}

##
## EKS Master Role
##
resource "aws_iam_role" "eks_master_role" {
  name = "eks_${local.stack_name}_master-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = merge({
    "Name" = "${local.stack_name}_eks-master-role"
  }, local.common_tags)
}

resource "aws_iam_role_policy_attachment" "eks-master-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_master_role.name
}


##
## EKS Worker Role
##
resource "aws_iam_role" "eks_worker_role" {
  name = "eks_${local.stack_name}_worker-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = merge({
    "Name" = "${local.stack_name}_eks-worker-role"
  }, local.common_tags)
}

resource "aws_iam_instance_profile" "eks_worker_profile" {
  name = "eks_${local.stack_name}_worker-instance-profile"
  role = aws_iam_role.eks_worker_role.name
}

resource "aws_iam_role_policy_attachment" "eks-worker-eks-worker-ssm-policy" {
  count      = var.eks_worker_ssm_access ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_worker_role.name
}

resource "aws_iam_role_policy_attachment" "eks-worker-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker_role.name
}

resource "aws_iam_role_policy_attachment" "eks-worker-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_worker_role.name
}

resource "aws_iam_role_policy_attachment" "eks-worker-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker_role.name
}


##
## Kubernetes OIDC provider
##
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.main.identity.0.oidc.0.issuer

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
}

##
## EKS Master User IAM role
##
resource "aws_iam_role" "eks_master_user_role" {
  name = "eks_${local.stack_name}_master-user-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
          "arn:aws:iam::340962741254:root"
          ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = merge({
    "Name" = "${local.stack_name}_eks-master-user-role"
  }, local.common_tags)
}

##
## EKS Developer User IAM role
##
resource "aws_iam_role" "eks_developer_user_role" {
  name = "eks_${local.stack_name}_developer-user-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = merge({
    "Name" = "${local.stack_name}_eks-developer-user-role"
  }, local.common_tags)
}

##
## Terraform Assume Role IAM role
##
resource "aws_iam_role" "terraform_role" {
  name = "${local.stack_name}-terraform-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::340962741254:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = merge({
    "Name" = "${local.stack_name}-terraform-role"
  }, local.common_tags)
}

data "aws_iam_policy_document" "terraform_iac_policy" {
  statement {
    effect = "Allow"
    actions = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "terraform_iac_policy" {
  name        = "${local.stack_name}-terraform-iac-policy"
  description = "Allows Terraform running in Shared account to manage AWS Digital Accounts."
  policy = data.aws_iam_policy_document.terraform_iac_policy.json
  tags = merge({
    "Name" = "${local.stack_name}-terraform-policy"
  }, local.common_tags)
}

resource "aws_iam_role_policy_attachment" "terraform_iac_role" {
  policy_arn = aws_iam_policy.terraform_iac_policy.arn
  role       = aws_iam_role.terraform_role.name
}