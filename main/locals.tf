locals {
  default_name           = "${var.service}-${var.environment}"
  log_group_prefix       = "/${var.service}/${var.environment}"
  terraform_state_bucket = "statpro.${data.aws_caller_identity.current.account_id}.terraform"
  trusted_networks       = split("\n", data.aws_s3_bucket_object.statpro_ips.body)
  s3_bucket_name         = "new-${var.service}-${var.environment}-${data.aws_region.current.name}"
  tags = merge(
    {
      "CostCenter"        = "Services"
      "Description"       = var.description
      "Environment"       = var.environment_long
      "ManagedWith"       = "Terraform"
      "Name"              = format("%s-%s", var.service, var.environment)
      "Product/Module"    = "Shared"
      "Repository"        = "github.com/statpro/stl"
      "Service/Component" = var.service
      "Team/Owner"        = "IT"
    },
    var.tags,
  )

  vpcs = [
    {
      id     = data.terraform_remote_state.network.outputs.vpc_id
      region = "ca-central-1"
      cidr   = data.terraform_remote_state.network.outputs.vpc_cidr
    }
  ]
}
