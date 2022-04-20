# Required tags
variable "aws_profile" {
  type = string
}

variable "service" {
  description = "Service Name"
  type        = string
}

# variable "service_version" {
#   description = "Service Version"
#   type        = string
# }

variable "environment" {
  description = "Resource environment tag (i.e. dev, stage, prod)"
  type        = string
}

variable "environment_long" {
  description = "Resource environment tag in long format (i.e. Development, Staging, Production)"
  type        = string
}

# Network
variable "vpcs" {
  type = list(object({
    id     = string
    region = string
    cidr   = string
  }))
}
variable "subnet_private_ids" {}
variable "internal_networks" {
  default = "10.0.0.0/9"
}
variable "stl_cpu" {
  type = number
}

variable "stl_memory" {
  type = number
}

variable "stl_pricing_cpu" {
  type = number
}

variable "stl_pricing_memory" {
  type = number
}

variable "stl_desired_count" {
  default = 1
}

variable "stl_pricing_desired_count" {
  default = 3
}
variable "stl_min_instances" {
  default = 1
}

variable "stl_max_instances" {
  default = 2
}

# If the average CPU utilization over a minute drops/rises beyond these
# thresholds then autoscaling with be kicked in
variable "stl_cpu_low_threshold" {}
variable "stl_cpu_high_threshold" {}

# Apache
variable "trusted_networks" {
  type = list(string)
}

variable "s3_bucket_name" {
  description = "S3 bucket for STL"
  type        = string
}






# Monitoring
variable "monitoring_cpu" {
  type    = string
  default = "256"
}

variable "monitoring_memory" {
  type    = string
  default = "512"
}


variable "lambda_timeout" {
  default = 30
}

variable "edi_preprocess_image_uri" {
}

# Required
variable "default_name" {
  description = "Name prefix to apply to all infrastructure"
  type        = string
}

# Configuration
variable "proxy_timeout" {
  description = "Total number of seconds before a proxied connection times out."
  type        = number
}

# Additional tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)

  default = {}
}

# Prerequisites

#variable "alb_arn" {}

# variable "ssl_cert" {
#   description = "Domain name used to lookup the SSL certificate to apply to the LB HTTPS listener"
#   type        = string
# }

variable "ssl_policy" {
  description = "SSL Policy for HTTPS Listeners"
  type        = string

  default = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
}

# Cloudwatch Logs/Alarms
variable "log_group_prefix" {
  description = "Prefix to apply to all cloudwatch logs"
  type        = string
}

variable "cloudwatch_log_retention_days" {
  description = "Number of days to retain Cloudwatch logs"
  default     = 30
}

variable "http_3xx_count" {
  description = "HTTP Code 3xx count threshhold"
  type        = string

  default = 200
}

variable "http_4xx_count" {
  description = "HTTP Code 4xx count threshhold"
  type        = string

  default = 200
}

variable "http_5xx_count" {
  description = "HTTP Code 5xx count threshhold"
  type        = string

  default = 50
}

# Datastore settings
variable "db_instance_class" {
  description = "Database instance class (ensure you adjust `db_max_connections` in conjunction)"
  type        = string
}

variable "db_storage" {
  description = "Allocated storage (in gigabytes) for DB"
  type        = string
}

variable "db_engine" {
}

variable "db_engine_version" {
}

variable "db_family" {
  default = "postgres13"
}

variable "db_name" {
  default = "stl"
}

variable "db_username" {
  description = "Database master username"
  type        = string

  default = "stl"
}

variable "rabbitmq_username" {
  description = "RabbitMQ Broker username"
  type        = string
  default     = "stl"
}

variable "db_max_connections" {
  description = "Maximum number of concurrent DB connections"
  type        = number
  # Maximum number of DB connections is set by AWS based on LEAST({DBInstanceClassMemory/9531392},5000)
  # These need to be shared across all containers
  default = 210
}

variable "maintenance_window" {}

variable "ec2_instance_type_prod" {
  default = "m4.2xlarge"
}

variable "ec2_instance_type_dev" {
  default = "m4.xlarge"
}
variable "rabbitmq_instance_type" {
}
variable "mq_engine" {
}
variable "use_multi_az" {
}
variable "mq_deployment_mode" {
}
variable "production" {
}

variable "importer_image_uri" {

}

variable "eventbridge_image_uri" {
}
variable "reactui_image_uri" {

}
variable "application_image_uri" {

}
variable "application_port" {

}
variable "pricing_image_uri" {

}
variable "remove_chars_image_uri" {

}
variable "fileemptycheck_image_uri" {

}
variable "jsontocsv_image_uri" {

}