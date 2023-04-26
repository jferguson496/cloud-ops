data "aws_region" "current" {
}

locals {
  worker-userdata = <<USERDATA
#cloud-config
ssh_authorized_keys: ${jsonencode(var.eks_worker_ssh_additional_keys)}
write_files:
  - path: /tmp/get-kubectl.sh
    owner: root:root
    permissions: '0744'
    encoding: b64
    content: ${filebase64("${var.scripts_dir}/get-kubectl.sh")}
  - path: /etc/systemd/system/kube-node-drainer.service
    owner: root:root
    permissions: '0755'
    encoding: b64
    content: ${filebase64("${var.scripts_dir}/kube-node-drainer.service")}
runcmd:
  - ${var.eks_worker_ssm_access ? "yum install -y ${var.eks_worker_ssm_rpm}" : "echo SSM access not enabled."}
  - /etc/eks/bootstrap.sh ${var.eks_worker_kubelet_extra_flags != "" ? "--kubelet-extra-args '${var.eks_worker_kubelet_extra_flags}'" : ""} --apiserver-endpoint '${aws_eks_cluster.main.endpoint}' --b64-cluster-ca '${aws_eks_cluster.main.certificate_authority.0.data}' '${local.stack_name}'
  - /tmp/get-kubectl.sh
  - systemctl enable kube-node-drainer && systemctl start kube-node-drainer
USERDATA
}
