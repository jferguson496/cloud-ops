data "aws_availability_zones" "available" {
}

locals {
  selected_availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_private_cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge({
    "Name" = "${local.stack_name}_main"
  }, local.common_tags)
}

resource "aws_vpc_ipv4_cidr_block_association" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.vpc_public_cidr_block
}


#
# Public subnet
#
resource "aws_subnet" "public" {
  for_each = toset(local.selected_availability_zones)

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.vpc_public_cidr_block, var.vpc_public_subnet_newbits, index(local.selected_availability_zones, each.key))

  depends_on = [
    aws_vpc_ipv4_cidr_block_association.public_subnet,
  ]

  tags = merge({
    "Name"                                      = "${local.stack_name}_public-${each.key}"
    "kubernetes.io/cluster/${local.stack_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }, local.common_tags)
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge({
    "Name" = "${local.stack_name}_main"
  }, local.common_tags)
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge({
    "Name" = "${local.stack_name}_public"
  }, local.common_tags)
}

resource "aws_route_table_association" "public" {
  for_each = toset(local.selected_availability_zones)

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat_gateway" {
  for_each = toset(local.selected_availability_zones)

  vpc = true

  tags = merge({
    "Name" = "${local.stack_name}_nat-gateway-${each.key}"
  }, local.common_tags)
}

resource "aws_nat_gateway" "public" {
  for_each = toset(local.selected_availability_zones)

  allocation_id = aws_eip.nat_gateway[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge({
    "Name" = "${local.stack_name}_public-${each.key}"
  }, local.common_tags)
}


#
# Private subnet
#
resource "aws_subnet" "private" {
  for_each = toset(local.selected_availability_zones)

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.vpc_private_cidr_block, var.vpc_private_subnet_newbits, index(local.selected_availability_zones, each.key))

  tags = merge({
    "Name"                                      = "${local.stack_name}_private-${each.key}"
    "kubernetes.io/cluster/${local.stack_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }, local.common_tags)
}

resource "aws_route_table" "private" {
  for_each = toset(local.selected_availability_zones)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public[each.key].id
  }

  propagating_vgws = [for vgw in aws_vpn_gateway.main : vgw.id]

  tags = merge({
    "Name" = "${local.stack_name}_private-${each.key}"
  }, local.common_tags)
}

resource "aws_route_table_association" "private" {
  for_each = toset(local.selected_availability_zones)

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}


#
# Database
#
resource "aws_db_subnet_group" "main" {
  name       = "${local.stack_name}_rds"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]

  tags = merge({
    "Name" = "${local.stack_name}_rds"
  }, local.common_tags)
}

resource "aws_elasticache_subnet_group" "main" {
  name       = local.stack_name
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]
}


#
# VPN
#
resource "aws_customer_gateway" "main" {
  for_each = var.vpn_connections

  bgp_asn     = each.value.customer_gateway.bgp_asn
  ip_address  = each.value.customer_gateway.ip_address
  type        = each.value.customer_gateway.type
  device_name = lookup(each.value.customer_gateway, "device_name", null)

  tags = merge({
    "Name" = each.value.customer_gateway.name
  }, local.common_tags)
}

resource "aws_vpn_gateway" "main" {
  for_each = var.vpn_connections

  vpc_id = aws_vpc.main.id

  tags = merge({
    "Name" = each.value.vpn_gateway.name
  }, local.common_tags)
}

resource "aws_vpn_connection" "main" {
  for_each = var.vpn_connections

  vpn_gateway_id      = aws_vpn_gateway.main[each.key].id
  customer_gateway_id = aws_customer_gateway.main[each.key].id
  type                = each.value.vpn_connection.type

  tags = merge({
    "Name" = each.value.vpn_connection.name
  }, local.common_tags)
}


#
# Endpoints
#
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  route_table_ids = [for table in aws_route_table.private : table.id]

  tags = merge({
    "Name" = "${local.stack_name}_s3"
  }, local.common_tags)
}
