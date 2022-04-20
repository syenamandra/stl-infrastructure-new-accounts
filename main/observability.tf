# data "terraform_remote_state" "observability" {
#   backend = "s3"

#   config = {
#     bucket  = "statpro.${data.aws_caller_identity.current.account_id}.terraform"
#     key     = var.observability_remote_state_key
#     profile = var.aws_profile
#     region  = var.aws_region
#   }
# }
