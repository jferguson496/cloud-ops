##
## EKS Master SG
##
resource "aws_security_group" "eks_master" {
  name   = "${local.stack_name}_master-sg"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    "Name" = "${local.stack_name}_master-sg"
  }, local.common_tags)
}

resource "aws_security_group_rule" "eks_master-ingress-worker-https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_master.id
  source_security_group_id = aws_security_group.eks_worker.id
  description              = "EKS Worker traffic"
}


##
## EKS Worker SG
##
resource "aws_security_group" "eks_worker" {
  name   = "${local.stack_name}_worker-sg"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    "Name" = "${local.stack_name}_worker-sg"
  }, local.common_tags)
}

resource "aws_security_group_rule" "eks_worker-ingress-self" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_worker.id
  source_security_group_id = aws_security_group.eks_worker.id
  description              = "EKS Worker traffic"
}

resource "aws_security_group_rule" "eks_worker-ingress-cluster" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_worker.id
  source_security_group_id = aws_security_group.eks_master.id
  description              = "EKS Master traffic"
}

resource "aws_security_group_rule" "eks_worker-ingress-ssh" {
  for_each          = var.eks_worker_ssh_access ? var.eks_worker_ssh_cidr_whitelist : {}
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_worker.id
  cidr_blocks       = [each.key]
  description       = each.value
}

resource "aws_security_group_rule" "eks_worker-ingress-lb" {
  for_each = { for target_group in var.eks_worker_asg_attach_alb_target_groups : target_group => {
    lb_sg = aws_security_group.lb[target_group].id
    port  = aws_lb_target_group.main[target_group].port
    }
  }

  type                     = "ingress"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_worker.id
  source_security_group_id = each.value.lb_sg
  description              = "Load Balancer traffic"
}

##
## RDS SG
##
resource "aws_security_group" "rds" {
  name   = "${local.stack_name}_rds"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_worker.id]
    description     = "EKS Worker traffic"
  }

  egress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_worker.id]
    description     = "EKS Worker traffic"
  }

  dynamic "ingress" {
    for_each = {
      for k, v in var.rds_instances["rmc-${var.project_env}"]["vpn_subnet_access"] : k => v if length(v) > 0
    }
    content {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ingress.value.source
      description = ingress.value.description
    }
  }

  # dynamic "ingress" {
  #   for_each = {
  #     for k, v in var.rds_instances["rmc-${var.project_env}"]["additional_access"] : k => v if length(v) > 0
  #   }
  #   content {
  #     from_port   = 5432
  #     to_port     = 5432
  #     protocol    = "tcp"
  #     cidr_blocks = ingress.value.source
  #     description = ingress.value.description
  #   }
  # }

  dynamic "egress" {
    for_each = {
      for k, v in var.rds_instances["rmc-${var.project_env}"]["vpn_subnet_access"] : k => v if length(v) > 0
    }
    content {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = egress.value.source
      description = egress.value.description
    }
  }

  tags = merge({
    "Name" = "${local.stack_name}_rds"
  }, local.common_tags)
}

##
## ElastiCache SG
##
resource "aws_security_group" "elasticache" {
  name   = "${local.stack_name}_elasticache"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_worker.id]
    description     = "EKS Worker traffic"
  }

  egress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_worker.id]
    description     = "EKS Worker traffic"
  }

  tags = merge({
    "Name" = "${local.stack_name}_elasticache"
  }, local.common_tags)
}
