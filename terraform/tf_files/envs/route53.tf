resource "aws_route53_zone" "primary" {
  for_each = var.r53_zones
  name     = each.key

  tags = {
    env         = var.project_env
    provisioner = "terraform"
  }
}

resource "aws_route53_record" "primary_caa" {
  for_each = length(var.r53_caa_records) > 0 ? aws_route53_zone.primary : set()
  zone_id  = each.value.zone_id
  name     = each.value.name
  type     = "CAA"
  ttl      = 300

  records = concat(formatlist("128 issue \"%s\"", var.r53_caa_records), formatlist("128 issuewild \"%s\"", var.r53_caa_records))
}
