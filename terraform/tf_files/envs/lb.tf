resource "aws_lb" "main" {
  for_each = var.lb_instances

  name = "${local.stack_name}-${each.key}"

  load_balancer_type = "application"
  subnets            = [for subnet in aws_subnet.public : subnet.id]
  security_groups    = [aws_security_group.lb[each.key].id]

  enable_deletion_protection = each.value.deletion_protection

  tags = merge({
    "Name" = "${local.stack_name}-${each.key}"
  }, local.common_tags)
}

resource "aws_lb_target_group" "main" {
  for_each = var.lb_instances

  name     = "${local.stack_name}-${each.key}"
  port     = each.value.target_group.port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  deregistration_delay          = lookup(each.value.target_group, "deregistration_delay", 60)
  load_balancing_algorithm_type = lookup(each.value.target_group, "load_balancing_algorithm_type", "round_robin")

  health_check {
    enabled             = true
    path                = lookup(each.value.target_group.healthcheck, "path", "/")
    interval            = lookup(each.value.target_group.healthcheck, "interval", 30)
    matcher             = lookup(each.value.target_group.healthcheck, "success_codes", "200")
    healthy_threshold   = lookup(each.value.target_group.healthcheck, "healthy_threshold", 3)
    unhealthy_threshold = lookup(each.value.target_group.healthcheck, "unhealthy_threshold", 3)
  }
}

locals {
  lb_listeners = merge([
    for lb_key, lb_value in var.lb_instances : {
      for listener_key, listener_value in lb_value.listeners : "${lb_key}_${listener_key}" => {
        lb       = lb_key
        listener = listener_value
      }
    }
  ]...)
  lb_listeners_certificates = merge([
    for lb_key, lb_value in var.lb_instances : merge([
      for listener_key, listener_value in lb_value.listeners : {
        for cert in listener_value.extra_certificates : "${lb_key}_${listener_key}_${cert}" => {
          listener    = "${lb_key}_${listener_key}"
          certificate = cert
        }
      } if length(lookup(listener_value, "extra_certificates", [])) > 0
    ]...)
  ]...)
}

resource "aws_lb_listener" "main" {
  for_each = try(local.lb_listeners != null ? local.lb_listeners : tomap(false), {})

  load_balancer_arn = aws_lb.main[each.value.lb].arn
  port              = each.value.listener.port
  protocol          = each.value.listener.protocol
  ssl_policy        = lookup(each.value.listener, "ssl_policy", null)
  certificate_arn   = try(aws_acm_certificate.cert[lookup(each.value.listener, "default_certificate", null)].arn, null)

  default_action {
    type             = each.value.listener.action_type
    target_group_arn = each.value.listener.action_type == "forward" ? aws_lb_target_group.main[each.value.lb].id : null

    dynamic "redirect" {
      for_each = each.value.listener.action_type == "redirect" ? [lookup(each.value.listener, "redirect", {})] : []

      content {
        path        = lookup(redirect.value, "path", null)
        host        = lookup(redirect.value, "host", null)
        port        = lookup(redirect.value, "port", null)
        protocol    = lookup(redirect.value, "protocol", null)
        query       = lookup(redirect.value, "query", null)
        status_code = lookup(redirect.value, "status_code", null)
      }
    }
  }
}

resource "aws_lb_listener_certificate" "main_extra" {
  for_each = local.lb_listeners_certificates != null ? local.lb_listeners_certificates : {}

  listener_arn    = aws_lb_listener.main[each.value.listener].arn
  certificate_arn = aws_acm_certificate.cert[each.value.certificate].arn
}

resource "aws_security_group" "lb" {
  for_each = var.lb_instances

  name   = "${local.stack_name}_${each.key}-lb-sg"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = merge([
      for listener in each.value.listeners : {
        for key, value in each.value.allowed_cidrs : "${value.cidr}_${listener.port}" => {
          port        = listener.port
          cidr        = value.cidr
          description = value.description
        }
      }
    ]...)

    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = [ingress.value.cidr]
      description = ingress.value.description
    }
  }

  tags = merge({
    "Name" = "${local.stack_name}_lb-sg"
  }, local.common_tags)
}

#
# WAF
#
resource "aws_wafv2_ip_set" "internal_service_whitelist" {
  for_each = {
    for k, v in var.lb_instances : k => v.waf.internal_service_whitelist if v.waf.internal_service_whitelist.enabled
  }

  name               = "internal-service-whitelist"
  description        = "List of IP addresses that can access internal service"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = each.value.ip_list

  tags = merge({
    "Name" = "${local.stack_name}_internal-service-whitelist"
  }, local.common_tags)
}

resource "aws_wafv2_ip_set" "admin_whitelist" {
  for_each = {
    for k, v in var.lb_instances : k => v.waf.admin_whitelist if v.waf.admin_whitelist.enabled
  }

  name               = "admin-whitelist"
  description        = "List of IP addresses that can access admin path"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = each.value.ip_list

  tags = merge({
    "Name" = "${local.stack_name}_admin-whitelist"
  }, local.common_tags)
}

resource "aws_wafv2_ip_set" "partner_whitelist" {
  for_each = {
    for k, v in var.lb_instances : k => v.waf.partner_whitelist if v.waf.partner_whitelist.enabled
  }

  name               = "partner_whitelist"
  description        = "List of IP addresses that can access partner api"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = each.value.ip_list

  tags = merge({
    "Name" = "${local.stack_name}_partner-whitelist"
  }, local.common_tags)
}

# resource "aws_wafv2_ip_set" "docusign_whitelist" {
#   for_each = {
#     for k, v in var.lb_instances : k => v.waf.docusign_whitelist if v.waf.docusign_whitelist.enabled
#   }

#   name               = "docusign_whitelist"
#   description        = "List of Whitelisted IP addresses for docusign"
#   scope              = "REGIONAL"
#   ip_address_version = "IPV4"
#   addresses          = each.value.ip_list

#   tags = merge({
#     "Name" = "${local.stack_name}_docusign-whitelist"
#   }, local.common_tags)
# }

resource "aws_wafv2_web_acl" "main" {
  for_each = {
    for k, v in var.lb_instances : k => v.waf if v.waf.enabled
  }

  name = "${local.stack_name}-${each.key}"

  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = each.value.cloudwatch
    sampled_requests_enabled   = each.value.cloudwatch
    metric_name                = "alb_waf_${local.stack_name}-${each.key}"
  }

  dynamic "rule" {
    for_each = each.value.managed_rules
    content {
      name     = "${rule.value.vendor}-${rule.value.name}"
      priority = rule.value.priority

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = rule.value.vendor

          dynamic "excluded_rule" {
            for_each = rule.value.excluded_rules

            content {
              name = excluded_rule.value
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = each.value.cloudwatch
        sampled_requests_enabled   = each.value.cloudwatch
        metric_name                = "alb_waf_${local.stack_name}-${each.key}_${rule.value.name}"
      }
    }
  }

  dynamic "rule" {
    for_each = each.value.country_whitelist.enabled ? [""] : []
    content {
      name     = "WhitelistedCountries"
      priority = each.value.country_whitelist.priority

      action {
        block {}
      }

      statement {
        not_statement {
          statement {
            geo_match_statement {
              country_codes = each.value.country_whitelist.whitelisted_countries
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = each.value.cloudwatch
        sampled_requests_enabled   = each.value.cloudwatch
        metric_name                = "alb_waf_${local.stack_name}-${each.key}_whitelisted-countries"
      }
    }
  }

  dynamic "rule" {
    for_each = each.value.rate_limit.enabled ? [""] : []
    content {
      name     = "RateLimit"
      priority = each.value.rate_limit.priority

      action {
        block {}
      }

      statement {
        rate_based_statement {
          limit              = each.value.rate_limit.limit
          aggregate_key_type = "IP"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = each.value.cloudwatch
        sampled_requests_enabled   = each.value.cloudwatch
        metric_name                = "alb_waf_${local.stack_name}-${each.key}_rate-limit"
      }
    }
  }

  dynamic "rule" {
    for_each = each.value.internal_service_whitelist.enabled ? [""] : []
    content {
      name     = "InternalServiceWhitelist"
      priority = each.value.internal_service_whitelist.priority

      action {
        allow {}
      }

      statement {
        and_statement {
          statement {
            byte_match_statement {
              field_to_match {
                single_header {
                  name = "host"
                }
              }
              search_string         = each.value.internal_service_whitelist.domain
              positional_constraint = "EXACTLY"
              text_transformation {
                type     = "NONE"
                priority = 0
              }
            }
          }
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.internal_service_whitelist[each.key].arn
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = each.value.cloudwatch
        sampled_requests_enabled   = each.value.cloudwatch
        metric_name                = "alb_waf_${local.stack_name}-${each.key}_internal-service-whitelist"
      }
    }
  }

  dynamic "rule" {
    for_each = each.value.internal_service_whitelist.enabled ? [""] : []
    content {
      name     = "InternalServiceBlockAll"
      priority = each.value.internal_service_whitelist.priority + 1

      action {
        block {}
      }

      statement {
        byte_match_statement {
          field_to_match {
            single_header {
              name = "host"
            }
          }
          search_string         = each.value.internal_service_whitelist.domain
          positional_constraint = "EXACTLY"
          text_transformation {
            type     = "NONE"
            priority = 0
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = each.value.cloudwatch
        sampled_requests_enabled   = each.value.cloudwatch
        metric_name                = "alb_waf_${local.stack_name}-${each.key}_internal-service-block-all"
      }
    }
  }

  dynamic "rule" {
    for_each = try(each.value.docusign_whitelist.enabled, null) != null ? [""] : []
    content {
      name     = "DocusignWhitelist"
      priority = each.value.docusign_whitelist.priority

      action {
        allow {}
      }

      statement {
        and_statement {
          statement {
            byte_match_statement {
              field_to_match {
                headers {
                  match_pattern {
                    included_headers = each.value.docusign_whitelist.headers
                  }
                  match_scope = "KEY"
                  oversize_handling = "NO_MATCH"
                }
              }
              search_string = "X-DocuSign-Signature-1"
              positional_constraint = "EXACTLY"
              text_transformation {
                type     = "NONE"
                priority = 0
              }
            }
          }
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.docusign_whitelist[each.key].arn
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = each.value.cloudwatch
        sampled_requests_enabled   = each.value.cloudwatch
        metric_name                = "alb_waf_${local.stack_name}-${each.key}_docusign-whitelist"
      }
    }
  }

  dynamic "rule" {
    for_each = each.value.admin_whitelist.enabled ? [""] : []
    content {
      name     = "AdminPathWhitelist"
      priority = each.value.admin_whitelist.priority

      action {
        allow {}
      }

      statement {
        and_statement {
          statement {
            byte_match_statement {
              field_to_match {
                uri_path {}
              }
              search_string         = each.value.admin_whitelist.path
              positional_constraint = "STARTS_WITH"
              text_transformation {
                type     = "NONE"
                priority = 0
              }
            }
          }
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.admin_whitelist[each.key].arn
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = each.value.cloudwatch
        sampled_requests_enabled   = each.value.cloudwatch
        metric_name                = "alb_waf_${local.stack_name}-${each.key}_admin-whitelist"
      }
    }
  }

  dynamic "rule" {
    for_each = each.value.admin_whitelist.enabled ? [""] : []
    content {
      name     = "AdminBlockAll"
      priority = each.value.admin_whitelist.priority + 1

      action {
        block {}
      }

      statement {
        byte_match_statement {
          field_to_match {
            uri_path {}
          }
          search_string         = each.value.admin_whitelist.path
          positional_constraint = "STARTS_WITH"
          text_transformation {
            type     = "NONE"
            priority = 0
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = each.value.cloudwatch
        sampled_requests_enabled   = each.value.cloudwatch
        metric_name                = "alb_waf_${local.stack_name}-${each.key}admin-path-block-all"
      }
    }
  }

  dynamic "rule" {
    for_each = each.value.partner_whitelist.enabled ? [""] : []
    content {
      name     = "PartnerApiPathWhitelist"
      priority = each.value.partner_whitelist.priority

      action {
        allow {}
      }

      statement {
        and_statement {
          statement {
            byte_match_statement {
              field_to_match {
                uri_path {}
              }
              search_string         = each.value.partner_whitelist.path
              positional_constraint = "STARTS_WITH"
              text_transformation {
                type     = "NONE"
                priority = 0
              }
            }
          }
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.partner_whitelist[each.key].arn
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = each.value.cloudwatch
        sampled_requests_enabled   = each.value.cloudwatch
        metric_name                = "alb_waf_${local.stack_name}-${each.key}_partner-whitelist"
      }
    }
  }

  dynamic "rule" {
    for_each = each.value.partner_whitelist.enabled ? [""] : []
    content {
      name     = "PartnerBlockAll"
      priority = each.value.partner_whitelist.priority + 1

      action {
        block {}
      }

      statement {
        byte_match_statement {
          field_to_match {
            uri_path {}
          }
          search_string         = each.value.partner_whitelist.path
          positional_constraint = "STARTS_WITH"
          text_transformation {
            type     = "NONE"
            priority = 0
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = each.value.cloudwatch
        sampled_requests_enabled   = each.value.cloudwatch
        metric_name                = "alb_waf_${local.stack_name}-${each.key}_partner-path-block-all"
      }
    }
  }
}

resource "aws_wafv2_web_acl_association" "main" {
  for_each = {
    for k, v in var.lb_instances : k => v if v.waf.enabled
  }

  resource_arn = aws_lb.main[each.key].arn
  web_acl_arn  = aws_wafv2_web_acl.main[each.key].arn
}
