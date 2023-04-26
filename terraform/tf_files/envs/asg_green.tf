data "aws_ami" "eks_worker_green" {
  filter {
    name   = "name"
    values = [var.eks_worker_green_ami_version == "latest" ? "amazon-eks-node-${var.eks_kubernetes_version_green}-*" : "amazon-eks-node-${var.eks_kubernetes_version_green}-${var.eks_worker_green_ami_version}"]
  }

  most_recent = true
  owners      = ["602401143452"]
}

resource "aws_launch_template" "worker_green" {
  name                   = "${local.stack_name}_worker-green"
  image_id               = data.aws_ami.eks_worker_green.id
  instance_type          = var.eks_worker_instance_type
  user_data              = base64encode(replace(local.worker-userdata, "\r\n", "\n"))
  key_name               = var.eks_worker_ssh_master_key
  update_default_version = true

  dynamic "instance_market_options" {
    for_each = var.eks_worker_request_spot_instances ? [""] : []
    content {
      market_type = "spot"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.eks_worker_profile.name
  }

  block_device_mappings {
    device_name = "/dev/xvda" # /dev/nvme0n1 ?

    ebs {
      volume_size           = var.eks_worker_asg_volume_size
      volume_type           = var.eks_worker_asg_volume_type
      delete_on_termination = true
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [aws_security_group.eks_worker.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge({
      "Name"                                      = "${local.stack_name}_eks-worker-green"
      "kubernetes.io/cluster/${local.stack_name}" = "owned"
    }, local.common_tags)
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge({
      "Name" = "eks-worker_${local.stack_name}"
    }, local.common_tags)
  }

  credit_specification {
    cpu_credits = "standard"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "worker_green" {
  name                = "${local.stack_name}_eks-worker-green"
  min_size            = var.eks_worker_green_asg_min_size
  max_size            = var.eks_worker_green_asg_max_size
  desired_capacity    = var.eks_worker_green_asg_min_size
  vpc_zone_identifier = [for subnet in aws_subnet.private : subnet.id]
  default_cooldown    = 30

  target_group_arns = [for target in var.eks_worker_asg_attach_alb_target_groups : aws_lb_target_group.main[target].arn]

  launch_template {
    id      = aws_launch_template.worker_green.id
    version = "$Latest"
  }

  enabled_metrics = var.eks_worker_asg_metrics ? [
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupPendingCapacity",
    "GroupMinSize",
    "GroupMaxSize",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupStandbyInstances",
    "GroupStandbyCapacity",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances",
  ] : []

  tags = [
    {
      key                 = "Name"
      value               = "${local.stack_name}_eks-worker-green"
      propagate_at_launch = false
    },
    {
      key                 = "k8s.io/cluster-autoscaler/${local.stack_name}"
      value               = "owned"
      propagate_at_launch = false
    },
    {
      key                 = "k8s.io/cluster-autoscaler/enabled"
      value               = "true"
      propagate_at_launch = false
    },
    {
      key                 = "project"
      value               = var.project_name
      propagate_at_launch = false
    },
    {
      key                 = "env"
      value               = var.project_env
      propagate_at_launch = false
    },
    {
      key                 = "provisioner"
      value               = "terraform"
      propagate_at_launch = false
    }
  ]

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}
