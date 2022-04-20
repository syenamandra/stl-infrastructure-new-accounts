resource "aws_cloudwatch_log_group" "importer" {
  name              = "${var.log_group_prefix}/importer"
  retention_in_days = var.cloudwatch_log_retention_days
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "application" {
  name              = "${var.log_group_prefix}/application"
  retention_in_days = var.cloudwatch_log_retention_days
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "reactui" {
  name              = "${var.log_group_prefix}/reactui"
  retention_in_days = var.cloudwatch_log_retention_days
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "pricing" {
  name              = "${var.log_group_prefix}/pricing"
  retention_in_days = var.cloudwatch_log_retention_days
  tags              = var.tags
}

