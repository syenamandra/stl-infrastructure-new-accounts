locals {
  vpc_region_map = {
    for vpc in var.vpcs : vpc.region => vpc
  }
}