locals {

}

resource "aws_ecs_service" "stl_pricing_engine_price" {
  name                    = "${var.default_name}-pricing-price"
  launch_type             = "FARGATE"
  cluster                 = aws_ecs_cluster.stl.id
  task_definition         = aws_ecs_task_definition.stl_pricing_engine_price.arn
  desired_count           = var.stl_desired_count
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


resource "aws_ecs_task_definition" "stl_pricing_engine_price" {
  family                   = "${var.default_name}-pricing-price-task"
  execution_role_arn       = aws_iam_role.stl_ecs_task.arn
  task_role_arn            = aws_iam_role.stl_ecs_task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.stl_pricing_cpu
  memory                   = var.stl_pricing_memory
  container_definitions    = data.template_file.stl_pricing_price_task_definition.rendered
  tags                     = var.tags
}

data "template_file" "stl_pricing_price_task_definition" {
  template = <<EOF
  [
    {
      "name": "${var.default_name}-pricing-price",
      "container_name": "${var.default_name}-pricing-price",
      "image": "${var.pricing_image_uri}",
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.pricing.name}",
          "awslogs-region": "${data.aws_region.current.name}",
          "awslogs-stream-prefix": "ecs"
        }
      },
        "dockerLabels": {
        "com.confluence.stl.service": "stl-pricing-service",
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
          "name"  : "COMPlus_EnableAlternateStackCheck",
          "value" : "1"
        },
        {
          "name"  : "STL_RUNTIME_MODE",
          "value" : "PRICE"
        },  
        {
          "name"  : "MESSAGEBROKER__MQ_HOSTNAME",
          "value" : "${aws_mq_broker.stl_rabbitmq.instances.0.endpoints.0}"
        },
        {
          "name"  : "MESSAGEBROKER__MQ_TOPICS__0",
          "value" : "stl.price.#"
        },
        {
          "name"  : "MESSAGEBROKER__MQ_TOPICS__1",
          "value" : "stl.ignite.#"
        },
        {
          "name"  : "STL_IGNITE_JAVA_MX",
          "value" : "10240"
        },
        {
          "name"  : "STL_IGNITE_HOME",
          "value" : "/opt/ignite/apache-ignite-2.12.0-bin"
        },
        {
          "name"  : "STL_HOME",
          "value" : "/stl-ignite"
        },
        {
          "name"  : "STL_IGNITE_SPRING_CONFIG",
          "value" : "file:////stl-ignite//startupContext.xml"
        },
        {
          "name"  : "STL_IGNITE_DEPLOYMENT",
          "value" : "/stl-ignite/stl-ignite-current.jar"
        },
        {
          "name"  : "STLDB_JDBC",
          "value" : "jdbc:postgresql://${aws_ssm_parameter.db_host.value}:5432/stl"
        },
        {
          "name"  : "CONNECTIONSTRINGS__STLDB",
          "value" : "Server=${aws_ssm_parameter.db_host.value};Port=5432;Database=stl;CommandTimeout=600"
        },
        {
          "name"  : "IGNITE_BUCKET_NAME",
          "value" : "${var.s3_bucket_name}"
        },
        {
          "name"  : "IGNITE_BUCKET_KEYPREFIX",
          "value" : "igniteconfig/"
        },
        {
          "name"  : "STL_IGNITE_JAVA_MS",
          "value" : "10240"
        },
        {
          "name"  : "STLDB_USER",
          "value" : "${var.db_username}"
        },   
        {
          "name"  : "MESSAGEBROKER__MQ_USERNAME",
          "value" : "${var.rabbitmq_username}"
        },
        {
          "name" : "ASPNETCORE_ENVIRONMENT",
          "value" : "${var.environment_long}"
        },
        {
          "name"  : "STL_IGNITE_ENVIRONMENT",
          "value" : "production"
        }
      ],
      "ulimits": [
        {
          "softLimit": 32768,
          "hardLimit": 32768,
          "name": "nofile"
        }
      ],
      "mountPoints": [],
      "volumesFrom": []
    }
  ]
 EOF 
}