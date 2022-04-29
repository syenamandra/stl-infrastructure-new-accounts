locals {
}

resource "aws_ecs_service" "stl_application" {
  name                    = "${var.default_name}-application"
  launch_type             = "FARGATE"
  cluster                 = aws_ecs_cluster.stl.id
  task_definition         = aws_ecs_task_definition.stl_application.arn
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

  service_registries {
    registry_arn   = aws_service_discovery_service.application_dns.arn
    container_name = "${var.default_name}-application"
    container_port = var.application_port
  }
}

resource "aws_ecs_task_definition" "stl_application" {
  family                   = "${var.default_name}-application-task"
  execution_role_arn       = aws_iam_role.stl_ecs_task.arn
  task_role_arn            = aws_iam_role.stl_ecs_task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.stl_cpu
  memory                   = var.stl_memory
  container_definitions    = data.template_file.stl_application_task_definition.rendered
  tags                     = var.tags
}

data "template_file" "stl_application_task_definition" {
  template = <<EOF
  [
    {
      "name": "${var.default_name}-application",
      "container_name": "${var.default_name}-application",
      "image": "${var.application_image_uri}",
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.application.name}",
          "awslogs-region": "${data.aws_region.current.name}",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "portMappings": [
        {
          "containerPort": 80
        },
        {
          "containerPort": 443
        }
      ],
      "dockerLabels": {
        "com.confluence.stl.service": "stl-application-service",
        "com.confluence.stl.environment" : "${var.environment_long}",
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
          "name" : "ASPNETCORE_ENVIRONMENT",
          "value" : "${var.environment_long}"
        },
        {
          "name"  : "STLDB_USER",
          "value" : "${var.db_username}"
        },
        {
          "name"  : "ONELOGIN__CLIENT_ID",
          "value" : "bae59370-8bee-013a-8349-026de717bd7c38403"
        },
        {
          "name"  : "ONELOGIN__CLIENT_SECRET",
          "value" : "b791d960391e954f9ad4d3ebae390f2ede0e9c23c959c0e21e18f54211a61c3e"
        },
        {
          "name"  : "ONELOGIN__DOMAIN",
          "value" : "https://confluence.onelogin.com"
        },
        {
          "name"  : "ONELOGIN__UI_REDIRECT",
          "value" : "https://internal-stl-dev-reactui-lb-973935463.ca-central-1.elb.amazonaws.com"
        },        
        {
          "name"  : "SAML2__IDPMETADATA",
          "value" : "https://app.onelogin.com/saml/metadata/3d458b22-32c1-4237-b40a-d3d34c60296f"
        },
        {
          "name"  : "SAML2__ISSUER",
          "value" : "STLApplication"
        },
        {
          "name"  : "SAML2__SIGNATUREALGORITHM",
          "value" : "http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"
        },
        {
          "name"  : "SAML2__CERTIFICATEVALIDATIONMODE",
          "value" : "ChainTrust"
        },
        {
          "name"  : "SAML2__REVOCATIONMODE",
          "value" : "NoCheck"
        },
        {
          "name"  : "CONNECTIONSTRINGS__STLDB",
          "value" : "Server=${aws_ssm_parameter.db_host.value};Port=5432;Database=stl;CommandTimeout=600"
        },
        {
          "name"  : "MESSAGEBROKER__MQ_HOSTNAME",
          "value" : "${aws_mq_broker.stl_rabbitmq.instances.0.endpoints.0}"
        },
        {
          "name"  : "MESSAGEBROKER__MQ_USERNAME",
          "value" : "${var.rabbitmq_username}"
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


resource "aws_service_discovery_private_dns_namespace" "application_dns" {
  name        = "${var.default_name}-${data.aws_region.current.name}.ecs.local"
  description = "${var.default_name}-${data.aws_region.current.name}-service-discovery"
  vpc         = data.aws_vpc.vpc.id
}


resource "aws_service_discovery_service" "application_dns" {
  name = "application"

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.application_dns.id
    routing_policy = "MULTIVALUE"

    dns_records {
      ttl  = 30
      type = "A"
    }
    dns_records {
      ttl  = 30
      type = "SRV"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  # SRV record requires exposed port and hence task definition must be in place before any changes to discovery can occur
  depends_on = [
    aws_ecs_task_definition.stl_application
  ]
}