resource "aws_eks_cluster" "main" {
  name     = local.stack_name
  role_arn = aws_iam_role.eks_master_role.arn

  version = var.eks_kubernetes_version

  enabled_cluster_log_types = var.eks_master_enabled_log_types

  vpc_config {
    security_group_ids = [aws_security_group.eks_master.id]
    subnet_ids         = [for subnet in aws_subnet.private : subnet.id]

    endpoint_private_access = var.eks_master_private_api_access
    endpoint_public_access  = var.eks_master_public_api_access
    public_access_cidrs     = var.eks_master_public_access_cidrs
  }

  tags = merge({
    "Name" = local.stack_name
  }, local.common_tags)

  depends_on = [
    aws_iam_role_policy_attachment.eks-master-AmazonEKSClusterPolicy,
  ]
}

resource "aws_cloudwatch_log_group" "eks_logs" {
  count             = length(var.eks_master_enabled_log_types) > 0 ? 1 : 0
  name              = "/aws/eks/${local.stack_name}/cluster"
  retention_in_days = var.eks_master_log_retention
}

output "eks_config_command" {
  value = <<EOT

aws eks update-kubeconfig \
--name ${aws_eks_cluster.main.id} \
--alias ${aws_eks_cluster.main.id} \
--role-arn ${aws_iam_role.eks_master_user_role.arn}
# (or ${aws_iam_role.eks_developer_user_role.arn})
EOT
}
