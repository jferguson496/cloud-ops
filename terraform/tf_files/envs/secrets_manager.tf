resource "aws_secretsmanager_secret" "init" {
  for_each = var.secrets_manager_init

  name = "${var.project_name}/${each.value}"
}
