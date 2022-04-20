output "ssm_parameter_db_host" {
  value = aws_ssm_parameter.db_host.arn
}

output "ssm_parameter_rabbitmq_username" {
  value = aws_ssm_parameter.rabbitmq_username.arn
}

output "ssm_parameter_rabbitmq_password" {
  value = aws_ssm_parameter.rabbitmq_password.arn
}

output "ssm_parameter_db_username" {
  value = aws_ssm_parameter.db_username.arn
}

output "ssm_parameter_db_password" {
  value = aws_ssm_parameter.db_password.arn
}