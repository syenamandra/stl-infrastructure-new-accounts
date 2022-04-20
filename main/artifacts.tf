data "terraform_remote_state" "artifact_repository" {
  backend = "s3"

  config = {
    bucket  = var.artifacts_remote_state_bucket
    key     = var.artifacts_remote_state_key
    profile = var.aws_profile
    region  = var.aws_region
  }
}
