resource "aws_elasticache_cluster" "main" {
  for_each = var.elasticache_instances

  cluster_id         = each.key
  engine             = each.value["engine"]
  node_type          = each.value["instance_class"]
  engine_version     = each.value["engine_version"]
  num_cache_nodes    = 1
  port               = 6379
  security_group_ids = [aws_security_group.elasticache.id]
  subnet_group_name  = aws_elasticache_subnet_group.main.id

  tags = merge({
    "Name" = each.key
  }, local.common_tags)
}
