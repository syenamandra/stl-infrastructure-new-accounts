# RDS S3 access role
resource "aws_iam_role" "stl_rds_s3" {
  name               = "${var.default_name}-rds-s3"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = var.tags
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "stl_rds_s3_access_policy" {
  name = "${var.default_name}-rds-s3-role-policy"
  role = aws_iam_role.stl_rds_s3.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
       "arn:aws:s3:::${var.s3_bucket_name}",
       "arn:aws:s3:::${var.s3_bucket_name}/*"
      ]
    }
  ]
}
POLICY

}

data "template_file" "rds_s3_secrets_policy" {
  template = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters"
      ],
      "Resource": [
        "arn:aws:ssm:$${region}:$${account_id}:parameter$${ssm_parameter_name_prefix}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": [
        "$${aws_kms_key}"
      ]
    }
  ]
}
EOF

  vars = {
    account_id                = data.aws_caller_identity.current.account_id
    region                    = data.aws_region.current.name
    ssm_parameter_name_prefix = "/${var.default_name}"
    aws_kms_key               = aws_kms_key.stl.arn
  }
}

resource "aws_iam_role_policy" "rds_s3_secrets_policy" {
  name   = "${var.default_name}-rds-secrets-role-policy"
  role   = aws_iam_role.stl_rds_s3.id
  policy = data.template_file.rds_s3_secrets_policy.rendered
}


# RDS Enhanced Monitoring role
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name               = "rds-enhanced-monitoring-${local.db_identifier}"
  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data "aws_iam_policy_document" "rds_enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

# Service Role for TMS S3 Access

resource "aws_iam_policy" "stl_tms_s3_access_policy" {
  name = "${var.default_name}-tms-s3-role-policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
       "arn:aws:s3:::${var.s3_bucket_name}",
       "arn:aws:s3:::${var.s3_bucket_name}/*"
      ]
    }
  ]
}
POLICY

}

resource "aws_iam_user" "stl_tms_s3" {
  name = "svc-${var.default_name}-tms-user"
  path = "/service_accounts/"
}

resource "aws_iam_policy_attachment" "stl_tms_s3_policy" {
  name       = "attachment"
  users      = [aws_iam_user.stl_tms_s3.name]
  policy_arn = aws_iam_policy.stl_tms_s3_access_policy.arn
}


# Lambda Role

resource "aws_iam_role" "lambda_role" {
  name               = "${var.default_name}-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  tags               = var.tags
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_execute_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

resource "aws_iam_role_policy_attachment" "lambda_eni_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaENIManagementAccess"
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "${var.default_name}-lambda-policy"
  role   = aws_iam_role.lambda_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:ca-central-1:243771075284:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "mq:DescribeBroker",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:ca-central-1:243771075284:log-group:/aws/lambda/stl-lambda-edi-preprocess:*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_secrets_policy" {
  name   = "${var.default_name}-secrets-role-policy"
  role   = aws_iam_role.lambda_role.id
  policy = data.template_file.stl_secrets_policy.rendered
}

# IAM roles for ECS
resource "aws_iam_role" "stl_ecs_task" {
  name               = "${var.default_name}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.assume_ecs_role_policy.json
  tags               = var.tags
}

data "aws_iam_policy_document" "assume_ecs_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "stl_ecs_task_policy" {
  role       = aws_iam_role.stl_ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "template_file" "stl_secrets_policy" {
  template = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters"
      ],
      "Resource": [
        "arn:aws:ssm:$${region}:$${account_id}:parameter$${ssm_parameter_name_prefix}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": [
        "$${aws_kms_key}"
      ]
    }
  ]
}
EOF

  vars = {
    account_id                = data.aws_caller_identity.current.account_id
    region                    = data.aws_region.current.name
    ssm_parameter_name_prefix = "/${var.default_name}"
    aws_kms_key               = aws_kms_key.stl.arn
  }
}

resource "aws_iam_role_policy" "stl_secrets_policy" {
  name   = "${var.default_name}-secrets-role-policy"
  role   = aws_iam_role.stl_ecs_task.id
  policy = data.template_file.stl_secrets_policy.rendered
}


data "template_file" "ecs_lambda_access" {
  template = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": [
        "${aws_lambda_function.edi_preprocess.arn}",
        "${aws_lambda_function.remove_chars.arn}",
        "${aws_lambda_function.jsontocsv.arn}",
        "${aws_lambda_function.filecheck.arn}"
      ]
    }
  ]
}
EOF

  vars = {
    account_id                = data.aws_caller_identity.current.account_id
    region                    = data.aws_region.current.name
    ssm_parameter_name_prefix = "/${var.default_name}"
    aws_kms_key               = aws_kms_key.stl.arn
  }
}

resource "aws_iam_role_policy" "stl_lambda_access_policy" {
  name   = "${var.default_name}-ecs-lambda-access"
  role   = aws_iam_role.stl_ecs_task.id
  policy = data.template_file.ecs_lambda_access.rendered
}


data "template_file" "ecs_s3_access" {
  template = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "${aws_s3_bucket.stl-cacentral.arn}",
        "${aws_s3_bucket.stl-cacentral.arn}/*"
      ]
    }
  ]
}
EOF

  vars = {
    account_id                = data.aws_caller_identity.current.account_id
    region                    = data.aws_region.current.name
    ssm_parameter_name_prefix = "/${var.default_name}"
    aws_kms_key               = aws_kms_key.stl.arn
  }
}

resource "aws_iam_role_policy" "stl_s3_access_policy" {
  name   = "${var.default_name}-ecs-s3-access"
  role   = aws_iam_role.stl_ecs_task.id
  policy = data.template_file.ecs_s3_access.rendered
}