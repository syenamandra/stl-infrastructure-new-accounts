data "aws_region" "current" {
}

data "aws_caller_identity" "current" {
}
data "aws_vpc" "vpc" {
  id = local.vpc_region_map[data.aws_region.current.name].id
}