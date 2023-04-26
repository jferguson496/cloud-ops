#
# Cloud init
#
locals {
  gha-runner-userdata = <<USERDATA
#cloud-config
write_files:
- path: /tmp/gha-runner-prep.sh
  owner: root:root
  permissions: '0744'
  encoding: b64
  content: ${filebase64("${var.scripts_dir}/gha-runner-prep.sh")}
- path: /scripts/image-prune.sh
  owner: root:root
  permissions: '0744'
  encoding: b64
  content: ${filebase64("${var.scripts_dir}/image-prune.sh")}
- path: /scripts/auto-restart.sh
  owner: root:root
  permissions: '0744'
  encoding: b64
  content: ${filebase64("${var.scripts_dir}/auto-restart.sh")}
- path: /var/spool/cron/crontabs/root
  owner: root:crontab
  permissions: '0600'
  content: |
    */15 * * * * /scripts/image-prune.sh
    */5 * * * * /scripts/auto-restart.sh
runcmd:
  - /tmp/gha-runner-prep.sh --archive ${var.gha_runner_agent_archive} --archive-hash ${var.gha_runner_agent_archive_hash} --url ${var.gha_runner_agent_url} --token ${var.gha_runner_agent_token} --prefix ${var.gha_runner_agent_name_prefix} %{if var.gha_runner_extra_labels != ""}--labels ${var.gha_runner_extra_labels}%{endif}
USERDATA
}

#
# AMI
#
data "aws_ami" "gha-runner" {
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  most_recent = true
  owners      = ["099720109477"]
}

#
# GHA Runner Security Group
#
resource "aws_security_group" "gha-runner" {
  name   = "gha-runner-sg"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    "Name" = "gha-runner-sg"
  }, local.common_tags)
}

#
# GHA Runner IAM
#
resource "aws_iam_role" "gha-runner_role" {
  name = "gha-runner_role"

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
}

resource "aws_iam_instance_profile" "gha-runner_profile" {
  name = "gha-runner-instance-profile"
  role = aws_iam_role.gha-runner_role.name
}

resource "aws_iam_role_policy_attachment" "eks-worker-eks-worker-ssm-policy" {
  count      = var.gha_runner_ssm_enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.gha-runner_role.name
}

resource "aws_iam_role_policy_attachment" "gha-runner-AmazonEC2ContainerRegistryPowerUser" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = aws_iam_role.gha-runner_role.name
}

#
# GHA Runner template
#
resource "aws_launch_template" "gha-runner" {
  name                   = "shared_gha-runner"
  image_id               = data.aws_ami.gha-runner.id
  instance_type          = var.gha_runner_instance_type
  user_data              = base64encode(local.gha-runner-userdata)
  key_name               = var.gha_runner_ssh_master_key
  update_default_version = true

  iam_instance_profile {
    name = aws_iam_instance_profile.gha-runner_profile.name
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = var.gha_runner_volume_size
      volume_type           = var.gha_runner_volume_type
      throughput            = var.gha_runner_volume_throughput
      iops                  = var.gha_runner_volume_iops
      delete_on_termination = true
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [aws_security_group.gha-runner.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge({
      "Name"          = "shared_gha-runner",
      "eks-whitelist" = "true"
    }, local.common_tags)
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge({
      "Name" = "shared_gha-runner"
    }, local.common_tags)
  }

  credit_specification {
    cpu_credits = "standard"
  }

  lifecycle {
    create_before_destroy = true
    #ignore_changes        = [image_id]
  }
}

#
# GHA Runner ASG
#
resource "aws_autoscaling_group" "gha-runner" {
  name                = "shared_gha-runner"
  min_size            = var.gha_runner_count
  max_size            = var.gha_runner_count
  desired_capacity    = var.gha_runner_count
  vpc_zone_identifier = [for subnet in aws_subnet.private : subnet.id]
  default_cooldown    = 15

  health_check_grace_period = 99999999 # Hack to disable healthchecks
  
  launch_template {
    id      = aws_launch_template.gha-runner.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }

    triggers = ["tag"]
  }

  tags = [
    {
      key                 = "Name"
      value               = "shared_gha-runner"
      propagate_at_launch = false
    },
    {
      key                 = "env"
      value               = "shared"
      propagate_at_launch = false
    },
    {
      key                 = "provisioner"
      value               = "terraform"
      propagate_at_launch = false
    },
    {
      key                 = "user_data_hash"
      value               = sha1(base64encode(local.gha-runner-userdata))
      propagate_at_launch = true
    }
  ]
}
