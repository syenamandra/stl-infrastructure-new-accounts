# NOTE: service_version should be populated via environment variable TF_VAR_service_version

# General
aws_profile      = "stl-production"
environment      = "prod"
environment_long = "Production"

# Remote State
network_remote_state_key       = "aws/account_network"
# application_remote_state_key   = "ra/prd/application/aws"
#observability_remote_state_key = "engineering/observability/prod/infrastructure"
#octopus_remote_state_key       = "devops/octopus/prod/ra"

# Load Balancer settings
#ssl_cert = "*.revolution.statpro.com"

# ECS
stl_min_instances_ca = 3
stl_max_instances_ca = 6

# RDS
db_instance_class = "db.m5.2xlarge"
db_storage        = "200"
#db_max_connections = 420
use_multi_az = true

# Cloudwatch
cloudwatch_log_retention_days = 30


# RabbitMQ
production             = "true"
rabbitmq_instance_type = "mq.m5.large"
mq_deployment_mode     = "CLUSTER_MULTI_AZ"



edi_preprocess_image_uri = "399497620873.dkr.ecr.ca-central-1.amazonaws.com/stl/stl-lambda-edi-preprocess:latest"

importer_image_uri = "399497620873.dkr.ecr.ca-central-1.amazonaws.com/stl/stl-import-service:latest"

eventbridge_image_uri = "399497620873.dkr.ecr.ca-central-1.amazonaws.com/stl/stl-lambda-eventbridge:latest"

application_image_uri = "399497620873.dkr.ecr.ca-central-1.amazonaws.com/stl/stl-application-server:latest"

pricing_image_uri = "399497620873.dkr.ecr.ca-central-1.amazonaws.com/stl/stl-price-service:latest"

reactui_image_uri = "399497620873.dkr.ecr.ca-central-1.amazonaws.com/stl/stl-react-ui:latest"

remove_chars_image_uri = "399497620873.dkr.ecr.ca-central-1.amazonaws.com/stl/stl-lambda-remove-chars:latest"