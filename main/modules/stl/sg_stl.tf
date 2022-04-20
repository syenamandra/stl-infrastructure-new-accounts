# ALB
resource "aws_security_group" "stl_alb" {
  description = "${var.default_name} ALB Access"
  name        = "${var.default_name}-ALB-SG"
  vpc_id      = data.aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      "Name" = format("%s-ALB-SG", var.default_name)
    },
  )
}

resource "aws_security_group_rule" "alb_onprem_ingress" {
  security_group_id = aws_security_group.stl_alb.id
  type              = "ingress"
  description       = "HTTP access from internal networks"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.internal_networks]
}

resource "aws_security_group_rule" "alb_ecs_access" {
  security_group_id        = aws_security_group.stl_alb.id
  type                     = "egress"
  description              = "HTTP to STL ECS"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_service_stl.id
}


# Postgres 
resource "aws_security_group" "postgres_access_stl" {
  description = "${var.default_name} Postgres Service"
  name        = "${var.default_name}-PG-SG"
  vpc_id      = data.aws_vpc.vpc.id
  ingress {
    description = "STL PostgreSQL Access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.internal_networks]
  }

  ingress {
    description = "STL PG Access from ECS"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [
      aws_security_group.ecs_service_stl.id
    ]
  }


  egress {
    description = "STL PostgreSQL S3 HTTPS Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    var.tags,
    {
      "Name" = format("%s-PG-SG", var.default_name)
    },
  )
}
# RabbitMQ Service
resource "aws_security_group" "rabbitmq_access_stl" {
  description = "${var.default_name} RabbiMQ Service"
  name        = "${var.default_name}-MQ-SG"
  vpc_id      = data.aws_vpc.vpc.id
  ingress {
    description = "STL RabbitMQ Access"
    from_port   = 5671
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = [var.internal_networks]
    security_groups = [
      aws_security_group.ecs_service_stl.id, aws_security_group.stl_lambda.id
    ]
  }
  ingress {
    description = "STL RabbitMQ Mgmt Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "STL RabbitMQ Outbound Access"
    from_port   = 5671
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    var.tags,
    {
      "Name" = format("%s-MQ-SG", var.default_name)
    },
  )
}
# ECS service
resource "aws_security_group" "ecs_service_stl" {
  description = "${var.default_name} ECS service"
  name        = "${var.default_name}-ECS-SG"
  vpc_id      = data.aws_vpc.vpc.id
  ingress {
    description = "All from bastion + self"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    cidr_blocks      = []
    description      = "allow http from LB"
    from_port        = 80
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = [aws_security_group.stl_alb.id]
    self             = false
    to_port          = 80
  }

  egress {
    description = "STL RabbitMQ Outbound Access"
    from_port   = 5671
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "STL PostgreSQL Access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "STL HTTPS Outbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "STL DNS Outbound - TCP"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "STL DNS Outbound - UDP"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "STL ECS Traffic Self"
    self        = true
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  tags = merge(
    var.tags,
    {
      "Name" = format("%s-ECS-SG", var.default_name)
    },
  )
}

#Lambda
resource "aws_security_group" "stl_lambda" {
  description = "${var.default_name} Lambda SG"
  name        = "${var.default_name}-lambda-sg"
  vpc_id      = data.aws_vpc.vpc.id
  ingress {
    description = "SELF"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  egress {
    description = "DNS (UDP)"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "DNS (TCP)"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "HTTPS outbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "MQ Outbound"
    from_port   = 5671
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    var.tags,
    {
      "Name" = format("%s-LAMBDA-SG", var.default_name)
    },
  )
}