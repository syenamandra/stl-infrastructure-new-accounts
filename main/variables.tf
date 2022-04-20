# Required
variable "aws_profile" {
  type = string
}

variable "aws_region" {
  default = "ca-central-1"
}

variable "service" {
  description = "Resource service tag"
  type        = string
  default     = "stl"
}

variable "description" {
  description = "Resource description tag"
  type        = string

  default = "Project St.Laurent - STL"
}

variable "environment" {
  description = "Resource environment tag (i.e. dev, stage, prod)"
  type        = string
}

variable "environment_long" {
  description = "Resource environment tag in long format (i.e. Development, Staging, Production)"
  type        = string
}

variable "network_remote_state_key" {
  description = "S3 key for remote state for network infrastructure"
  type        = string
}



# Artifact Repository remote state
variable "artifacts_remote_state_bucket" {
  default = "statpro-its-terraform-shared"
}

variable "artifacts_remote_state_key" {
  default = "devops/artifacts"
}


# General
# variable "service_version" {
#   description = "Version of ECR containers to deploy."
#   type        = string
# }

# Load Balancer
# variable "ssl_cert" {
#   description = "Domain name used to lookup the SSL certificate to apply to the LB HTTPS listener"
#   type        = string
# }

# Configuration
variable "proxy_timeout" {
  description = "Total number of seconds before a proxied connection times out."
  type        = number
  default     = 100
}

# ECS
# Note: Desired count is only used when first creating the ECS service
# Therafter it is controlled by the autoscaling policy - so we just default to 1
variable "stl_desired_count_ca" {
  description = "Desired number of instances of services in CA."
  default     = 1
}

variable "stl_min_instances_ca" {
  description = "Minimum number of instances of the services to run in CA"
}

variable "stl_max_instances_ca" {
  description = "Maximum number of instances of the services to run in EU."
}

variable "stl_cpu" {
  description = "vCPU to allocate to STL service tasks."
  default     = 1024
}

variable "stl_memory" {
  description = "Memory to allocate to STL service tasks."
  default     = 2048
}

variable "stl_pricing_cpu" {
  description = "vCPU to allocate to STL service tasks."
  default     = 2048
}

variable "stl_pricing_memory" {
  description = "Memory to allocate to STL service tasks."
  default     = 16384
}

# If the average CPU utilization over a minute drops to this threshold, the number of containers will be reduced (but not below stl_min_instances).
variable "stl_cpu_low_threshold" {
  description = "If the average CPU utilization over a minute drops to this threshold, the number of containers will be reduced (but not below stl_min_instances)."
  default     = 30
}

# If the average CPU utilization over a minute rises to this threshold the number of containers will be increased (but not above stl_max_instances).
variable "stl_cpu_high_threshold" {
  description = "If the average CPU utilization over a minute rises to this threshold the number of containers will be increased (but not above stl_max_instances)."
  default     = 65
}

# RDS
variable "db_instance_class" {
  description = "Database instance class"
  type        = string
}

variable "db_storage" {
  description = "Allocated storage (in gigabytes) for DB"
  type        = string
}

variable "db_engine" {
  default = "postgres"
}

variable "db_engine_version" {
  default = "13.4"
}

variable "maintenance_window" {
  default = "sun:05:00-sun:10:00"
}

# Monitoring
variable "cloudwatch_log_retention_days" {
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)

  default = {}
}

#RabbitMQ

variable "mq_engine" {
  default = "3.8.11"
}
variable "use_multi_az" {
}
variable "rabbitmq_instance_type" {
}
variable "mq_deployment_mode" {
}
variable "production" {
}
variable "edi_preprocess_image_uri" {
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
  default = "80"
}
variable "pricing_image_uri" {

}

variable "remove_chars_image_uri" {

}
variable "fileemptycheck_image_uri" {

}
variable "jsontocsv_image_uri" {

}