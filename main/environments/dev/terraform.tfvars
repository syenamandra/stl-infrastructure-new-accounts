# NOTE: service_version should be populated via environment variable TF_VAR_service_version

# General
aws_profile      = "stl-development"
environment      = "dev"
environment_long = "Development"

# Remote State
network_remote_state_key       = "aws/account_network"
#application_remote_state_key   = "ra/dev/application/aws"
#observability_remote_state_key = "engineering/observability/dev/infrastructure"
#octopus_remote_state_key       = "devops/octopus/dev/ra"

# ECS
stl_min_instances_ca = 3
stl_max_instances_ca = 6



# RDS
# db.t2.small is minimum supported size that supports encryption at rest
db_instance_class = "db.m5.large"
db_storage        = "200"
use_multi_az      = false


# Cloudwatch
cloudwatch_log_retention_days = 30

# RabbitMQ
production             = "false"
rabbitmq_instance_type = "mq.t3.micro"
mq_deployment_mode     = "SINGLE_INSTANCE"


edi_preprocess_image_uri = "144717148227.dkr.ecr.ca-central-1.amazonaws.com/stl/stl-lambda-edi-preprocess:latest"

importer_image_uri = "144717148227.dkr.ecr.ca-central-1.amazonaws.com/stl/stl-import-service:latest"

eventbridge_image_uri = "144717148227.dkr.ecr.ca-central-1.amazonaws.com/stl/stl-lambda-eventbridge:latest"

application_image_uri = "144717148227.dkr.ecr.ca-central-1.amazonaws.com/stl/stl-application-server:latest"

pricing_image_uri = "144717148227.dkr.ecr.ca-central-1.amazonaws.com/stl/stl-price-service:latest"

reactui_image_uri = "144717148227.dkr.ecr.ca-central-1.amazonaws.com/stl/stl-react-ui:latest"

remove_chars_image_uri = "144717148227.dkr.ecr.ca-central-1.amazonaws.com/stl/stl-lambda-remove-chars:latest"
fileemptycheck_image_uri = "144717148227.dkr.ecr.ca-central-1.amazonaws.com/stl/stl-lambda-file-empty-check:latest"
jsontocsv_image_uri = "144717148227.dkr.ecr.ca-central-1.amazonaws.com/stl/stl-lambda-jsontocsv:latest"