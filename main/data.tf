data "aws_caller_identity" "current" {}

data "aws_region" "current" {
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket  = "statpro.${data.aws_caller_identity.current.account_id}.terraform"
    key     = var.network_remote_state_key
    profile = var.aws_profile
    region  = var.aws_region
  }
}

data "aws_s3_bucket_object" "statpro_ips" {
  bucket = "statpro.240843251169.meta.ca-central-1"
  key    = "ips-v4"
}

# data "aws_kms_key" "stl" {
#   arn = aws_kms_key.stl.arn
# }