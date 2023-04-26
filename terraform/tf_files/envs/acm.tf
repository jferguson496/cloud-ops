resource "aws_acm_certificate" "cert" {
  for_each = var.acm_certificates

  domain_name               = each.key
  subject_alternative_names = each.value.san
  validation_method         = "DNS"

  tags = {
    Name        = each.key
    env         = var.project_env
    provisioner = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  acm_validation_domains = merge([
    for key, cert in aws_acm_certificate.cert : {
      for dvo in cert.domain_validation_options : dvo.domain_name => {
        cert   = key
        zone   = var.acm_certificates[key].r53_zone
        name   = dvo.resource_record_name
        record = dvo.resource_record_value
        type   = dvo.resource_record_type
      }
    }
  ]...)
}

resource "aws_route53_record" "cert_validation" {
  for_each = local.acm_validation_domains

  zone_id = aws_route53_zone.primary[each.value.zone].zone_id

  allow_overwrite = true

  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = "60"
}

# resource "aws_acm_certificate_validation" "acm_cert_validation" {
#   for_each = local.acm_validation_domains

#   certificate_arn         = aws_acm_certificate.cert[each.value.cert].arn
#   validation_record_fqdns = [aws_route53_record.cert_validation[each.value.cert].fqdn]
# }
