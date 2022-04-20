resource "aws_mq_broker" "stl_rabbitmq" {
  broker_name        = "${var.default_name}-rabbitmq"
  engine_type        = "RabbitMQ"
  engine_version     = var.mq_engine
  deployment_mode    = var.mq_deployment_mode
  host_instance_type = var.rabbitmq_instance_type
  security_groups    = [aws_security_group.rabbitmq_access_stl.id]

  logs {
    general = true
  }

  user {
    username = var.rabbitmq_username
    password = aws_ssm_parameter.rabbitmq_password.value
  }
  subnet_ids          = var.mq_deployment_mode == "SINGLE_INSTANCE" ? [var.subnet_private_ids[0]] : var.subnet_private_ids
  publicly_accessible = false
  tags                = var.tags
}