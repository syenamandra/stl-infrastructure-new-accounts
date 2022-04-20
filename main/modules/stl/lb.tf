resource "aws_alb" "stl_application" {
  name                       = "${var.default_name}-application"
  internal                   = true
  subnets                    = var.subnet_private_ids
  security_groups            = [aws_security_group.stl_alb.id]
  enable_deletion_protection = "true"
  tags                       = var.tags


  lifecycle {
    prevent_destroy = "true"
  }
}





# resource "aws_alb_target_group" "gateway_1" {
#   name        = "${var.default_name}-HTTPS-1"
#   port        = "443"
#   protocol    = "HTTPS"
#   target_type = "ip"
#   vpc_id      = data.aws_vpc.vpc.id

#   health_check {
#     path     = "/healthz"
#     port     = "8080"
#     protocol = "HTTPS"
#     matcher  = "200"
#   }
# }

# resource "aws_alb_listener" "test_https" {
#   load_balancer_arn = data.aws_alb.gateway.arn
#   port              = local.test_listener_port
#   protocol          = "HTTPS"

#   ssl_policy      = var.ssl_policy
#   certificate_arn = data.aws_acm_certificate.cert.arn

#   default_action {
#     target_group_arn = aws_alb_target_group.gateway_1.arn
#     type             = "forward"
#   }

#   lifecycle {
#     ignore_changes = [
#       default_action
#     ]
#   }
# }