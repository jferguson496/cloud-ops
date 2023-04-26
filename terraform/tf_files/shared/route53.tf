resource "aws_route53_zone" "main" {
  for_each = var.r53_zones
  name     = each.key

  tags = {
    env         = "shared"
    provisioner = "terraform"
  }
}

locals {
  route53_records = merge([
    for zone_name, zone_value in var.r53_zones : {
      for record_name, record_value in zone_value : "${aws_route53_zone.main[zone_name].zone_id}_${record_name}.${zone_name}_${record_value.type}" => {
        name    = "${record_name}.${zone_name}"
        ttl     = record_value.ttl
        type    = record_value.type
        records = record_value.records
        zone_id = aws_route53_zone.main[zone_name].zone_id
      }
    }
  ]...)
}

resource "aws_route53_record" "main" {
  for_each = local.route53_records

  zone_id = each.value.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.ttl

  records = each.value.records
}

#
# Twilio proxy
#
data "aws_route53_zone" "twilio_proxy" {
  name         = var.twilio_proxy_r53_zone
  private_zone = false
}

resource "aws_route53_record" "twilio_proxy" {
  zone_id = data.aws_route53_zone.twilio_proxy.zone_id
  name    = var.twilio_proxy_r53_domain
  type    = "A"
  ttl     = "300"
  records = [aws_eip.twilio_proxy.public_ip]
}

output "twilio_proxy_domain" {
  value = aws_route53_record.twilio_proxy.name
}
