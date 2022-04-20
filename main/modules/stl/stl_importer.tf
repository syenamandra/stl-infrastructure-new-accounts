locals {
}

resource "aws_ecs_service" "stl_importer" {
  name                    = "${var.default_name}-importer"
  launch_type             = "FARGATE"
  cluster                 = aws_ecs_cluster.stl.id
  task_definition         = aws_ecs_task_definition.stl_importer.arn
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

resource "aws_ecs_task_definition" "stl_importer" {
  family                   = "${var.default_name}-importer-task"
  execution_role_arn       = aws_iam_role.stl_ecs_task.arn
  task_role_arn            = aws_iam_role.stl_ecs_task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.stl_cpu
  memory                   = var.stl_memory
  container_definitions    = data.template_file.stl_importer_task_definition.rendered
  tags                     = var.tags
}

data "template_file" "stl_importer_task_definition" {
  template = <<EOF
  [
    {
      "name": "${var.default_name}-importer",
      "container_name": "${var.default_name}-importer",
      "image": "${var.importer_image_uri}",
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.importer.name}",
          "awslogs-region": "${data.aws_region.current.name}",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "portMappings": [
        {
          "containerPort": 8080
        },
        {
          "containerPort": 8081
        }
      ],
      "dockerLabels": {
        "com.confluence.stl.service": "stl-import-service",
        "com.confluence.stl.environment" : "development",
        "com.confluence.stl.version": "1.0.0"
      },
      "secrets": [
        {
          "name"  : "MESSAGEBROKER__MQ_PASSWORD",
          "valueFrom" : "${aws_ssm_parameter.rabbitmq_password.arn}"
        },
        {
          "name"  : "STLDB_PASSWORD",
          "valueFrom" : "${aws_ssm_parameter.db_password.arn}"
        }
      ],
      "environment": [
        {
          "name"  : "LOCALSTACK_DEPLOY",
          "value" : "false"
        },
        {
          "name"  : "MESSAGEBROKER__MQ_HOSTNAME",
          "value" : "${aws_mq_broker.stl_rabbitmq.instances.0.endpoints.0}"
        },
        {
          "name"  : "MESSAGEBROKER__MQ_TOPICS__0",
          "value" : "stl.oasis.#"
        },
        {
          "name"  : "MESSAGEBROKER__MQ_TOPICS__1",
          "value" : "stl.process.#"
        },
        {
          "name"  : "MESSAGEBROKER__MQ_EXCHANGENAME",
          "value" : "${var.rabbitmq_username}"
        },
        {
          "name"  : "CONNECTIONSTRINGS__STLDB",
          "value" : "Server=${aws_ssm_parameter.db_host.value};Port=5432;Database=stl;CommandTimeout=600"
        },
        {
          "name"  : "MESSAGEBROKER__MQ_USERNAME",
          "value" : "${var.rabbitmq_username}"
        },
        {
          "name"  : "STLDB_USER",
          "value" : "${var.db_username}"
        },
        {
          "name" : "ASPNETCORE_ENVIRONMENT",
          "value" : "${var.environment_long}"
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