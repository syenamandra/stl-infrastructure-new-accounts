locals {
  ssm_parameter_name_db_username       = "/${var.default_name}/db/username"
  ssm_parameter_name_db_password       = "/${var.default_name}/db/password"
  ssm_parameter_name_db_host           = "/${var.default_name}/db/host"
  ssm_parameter_name_rabbitmq_username = "/${var.default_name}/rabbitmq/username"
  ssm_parameter_name_rabbitmq_password = "/${var.default_name}/rabbitmq/password"
  db_password                          = random_password.db_password.result
  rabbitmq_password                    = random_password.rabbitmq_password.result
}

# Random SecureStrings to use as master passwords unless one is specified
resource "random_password" "db_password" {
  length           = 20
  override_special = "!$%&*()-_=+[]{}<>:?"
}
resource "random_password" "rabbitmq_password" {
  length           = 20
  override_special = "!#$%&*()-_+[]{}<>?"
}
resource "aws_ssm_parameter" "db_host" {
  name  = local.ssm_parameter_name_db_host
  type  = "SecureString"
  value = replace(module.db.this_db_instance_endpoint, "/:.*/", "")
  tags  = var.tags
}

resource "aws_ssm_parameter" "db_username" {
  name      = local.ssm_parameter_name_db_username
  type      = "SecureString"
  key_id    = aws_kms_key.stl.arn
  value     = var.db_username
  overwrite = true
  tags      = var.tags
}

resource "aws_ssm_parameter" "db_password" {
  name   = local.ssm_parameter_name_db_password
  type   = "SecureString"
  key_id = aws_kms_key.stl.arn
  value  = local.db_password
  tags   = var.tags

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "rabbitmq_username" {
  name      = local.ssm_parameter_name_rabbitmq_username
  type      = "SecureString"
  key_id    = aws_kms_key.stl.arn
  value     = var.db_username
  overwrite = true
  tags      = var.tags
}

resource "aws_ssm_parameter" "rabbitmq_password" {
  name   = local.ssm_parameter_name_rabbitmq_password
  type   = "SecureString"
  key_id = aws_kms_key.stl.arn
  value  = local.rabbitmq_password
  tags   = var.tags

  lifecycle {
    ignore_changes = [value]
  }
}