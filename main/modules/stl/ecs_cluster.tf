resource "aws_ecs_cluster" "stl" {
  name               = "${var.default_name}-cluster"
  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
  }
  tags = var.tags
}