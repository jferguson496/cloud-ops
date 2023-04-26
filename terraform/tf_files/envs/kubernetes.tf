data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.id
  provider = aws.aws-eks
}

provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.main.token
}

resource "kubernetes_cluster_role" "node_drainer" {
  metadata {
    name = "system:node-drainer"
  }

  rule {
    api_groups = [""]
    resources  = ["pods/eviction"]
    verbs      = ["create"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["statefulsets", "daemonsets", "replicasets"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "node_drainer" {
  metadata {
    name = "system:node-drainer"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:node-drainer"
  }

  subject {
    kind      = "Group"
    name      = "system:node-drainers"
    api_group = "rbac.authorization.k8s.io"
  }
}
locals {
  aws-auth = <<EOF
- rolearn: ${aws_iam_role.eks_worker_role.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
    - system:node-drainers
- rolearn: ${aws_iam_role.eks_master_user_role.arn}
  username: system:master:{{SessionName}}
  groups:
    - system:masters
- rolearn: ${aws_iam_role.eks_developer_user_role.arn}
  username: developer:{{SessionName}}
  groups:
    - developers
%{if var.eks_master_authorize_gha_runner~}
- rolearn: ${var.eks_master_gha_runner_role}
  username: system:master:{{SessionName}}
  groups:
    - system:masters
%{endif~}
EOF
}
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = replace(local.aws-auth, "\r\n", "\n")
  }
}

resource "kubernetes_pod_disruption_budget" "coredns" {
  metadata {
    name      = "coredns"
    namespace = "kube-system"
  }
  spec {
    min_available = 1
    selector {
      match_labels = {
        k8s-app = "kube-dns"
      }
    }
  }
}
