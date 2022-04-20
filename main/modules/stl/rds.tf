locals {
  db_identifier         = "${var.default_name}-pg"
  replica_db_identifier = "${var.default_name}-replica-pg"
  snapshot_identifier   = "${local.db_identifier}-${data.aws_region.current.name}"
}

module "db" {
  source                    = "github.com/terraform-aws-modules/terraform-aws-rds.git?ref=v2.5.0"
  identifier                = local.db_identifier
  engine                    = var.db_engine
  engine_version            = var.db_engine_version
  instance_class            = var.db_instance_class
  family                    = var.db_family
  port                      = "5432"
  allocated_storage         = var.db_storage
  storage_encrypted         = true
  kms_key_id                = aws_kms_key.stl.arn
  create_db_instance        = true
  name                      = var.db_name
  username                  = var.db_username
  password                  = aws_ssm_parameter.db_password.value
  vpc_security_group_ids    = [aws_security_group.postgres_access_stl.id]
  subnet_ids                = var.subnet_private_ids
  multi_az                  = var.use_multi_az
  create_db_subnet_group    = true
  create_db_parameter_group = false
  monitoring_role_arn       = aws_iam_role.rds_enhanced_monitoring.arn
  monitoring_interval       = 60

  # snapshot_identifier     = "${local.snapshot_identifier}"
  final_snapshot_identifier = local.snapshot_identifier
  skip_final_snapshot       = false

  # This DB should be recreatable as any long-lived information should be boot-strapped/saved in final snapshot
  deletion_protection = false
  backup_window       = "00:00-05:00"
  maintenance_window  = var.maintenance_window

  tags = var.tags
}

# DB Instance Role Association
resource "aws_db_instance_role_association" "stl_rds_s3_role_association" {
  db_instance_identifier = local.db_identifier
  feature_name           = "s3Import"
  role_arn               = aws_iam_role.stl_rds_s3.arn
}