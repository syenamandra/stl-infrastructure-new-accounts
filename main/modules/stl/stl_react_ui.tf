locals {
}

resource "aws_ecs_service" "stl_reactui" {
  name                    = "${var.default_name}-reactui"
  launch_type             = "FARGATE"
  cluster                 = aws_ecs_cluster.stl.id
  task_definition         = aws_ecs_task_definition.stl_reactui.arn
  desired_count           = var.stl_desired_count
  tags                    = var.tags
  propagate_tags          = "SERVICE"
  enable_ecs_managed_tags = true
  platform_version        = "LATEST"

  network_configuration {
    subnets          = var.subnet_private_ids
    assign_public_ip = false

    security_groups = [
      aws_security_group.ecs_service_stl.id,
    ]
  }
}

resource "aws_ecs_task_definition" "stl_reactui" {
  family                   = "${var.default_name}-reactui-task"
  execution_role_arn       = aws_iam_role.stl_ecs_task.arn
  task_role_arn            = aws_iam_role.stl_ecs_task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.stl_cpu
  memory                   = var.stl_memory
  container_definitions    = data.template_file.stl_reactui_task_definition.rendered
  tags                     = var.tags
}

data "template_file" "stl_reactui_task_definition" {
  template = <<EOF
  [
    {
      "name": "${var.default_name}-reactui",
      "container_name": "${var.default_name}-reactui",
      "image": "${var.reactui_image_uri}",
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.reactui.name}",
          "awslogs-region": "${data.aws_region.current.name}",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "portMappings": [
        {
          "containerPort": 80
        }
      ],
      "dockerLabels": {
        "com.confluence.stl.service": "stl-react-ui-service",
        "com.confluence.stl.environment" : "development",
        "com.confluence.stl.version": "1.0.0"
      },
      "environment": [
        {
          "name"  : "REACT_APP_AGGRID_KEY",
          "value" : "NoKeyNeeded"
        },
        {
          "name"  : "REACT_APP_API_URL",
          "value" : "${aws_service_discovery_service.application_dns.name}.${aws_service_discovery_private_dns_namespace.application_dns.name}"
        }
      ],
      "ulimits": [
        {
          "softLimit": 8192,
          "hardLimit": 8192,
          "name": "nofile"
        }
      ],
      "mountPoints": [],
      "volumesFrom": []
    }
  ]
 EOF 
}