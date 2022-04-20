provider "aws" {
  alias   = "ca"
  profile = var.aws_profile
  region  = "ca-central-1"
}

module "stl_ca" {
  source = "./modules/stl"
  providers = {
    aws = aws.ca
  }

  # General
  aws_profile      = var.aws_profile
  service          = var.service
  environment      = var.environment
  environment_long = var.environment_long
  default_name     = local.default_name
  s3_bucket_name   = local.s3_bucket_name


  # Network
  vpcs                  = local.vpcs
  subnet_private_ids = data.terraform_remote_state.network.outputs.subnet_private_ids

  # ECS
  stl_desired_count      = var.stl_desired_count_ca
  stl_min_instances      = var.stl_min_instances_ca
  stl_max_instances      = var.stl_max_instances_ca
  stl_cpu                = var.stl_cpu
  stl_memory             = var.stl_memory
  stl_pricing_cpu        = var.stl_pricing_cpu
  stl_pricing_memory     = var.stl_pricing_memory
  stl_cpu_low_threshold  = var.stl_cpu_low_threshold
  stl_cpu_high_threshold = var.stl_cpu_high_threshold

  importer_image_uri     = var.importer_image_uri
  application_image_uri  = var.application_image_uri
  reactui_image_uri      = var.reactui_image_uri
  application_port       = var.application_port
  pricing_image_uri      = var.pricing_image_uri
  remove_chars_image_uri = var.remove_chars_image_uri

  # RabbitMQ
  mq_engine              = var.mq_engine
  rabbitmq_instance_type = var.rabbitmq_instance_type
  mq_deployment_mode     = var.mq_deployment_mode
  production             = var.production

  # S3
  trusted_networks = local.trusted_networks


  # Config
  proxy_timeout = var.proxy_timeout

  # Data store
  db_engine          = var.db_engine
  db_engine_version  = var.db_engine_version
  db_instance_class  = var.db_instance_class
  db_storage         = var.db_storage
  maintenance_window = var.maintenance_window
  use_multi_az       = var.use_multi_az

  #Monitoring
  log_group_prefix                  = local.log_group_prefix
  cloudwatch_log_retention_days     = var.cloudwatch_log_retention_days


  #Lambda
  edi_preprocess_image_uri = var.edi_preprocess_image_uri
  eventbridge_image_uri    = var.eventbridge_image_uri
  fileemptycheck_image_uri = var.fileemptycheck_image_uri
  jsontocsv_image_uri      = var.jsontocsv_image_uri

  tags = merge(
    local.tags,
    {
      "BusinessRegion" = "CA"
    },
  )
}
