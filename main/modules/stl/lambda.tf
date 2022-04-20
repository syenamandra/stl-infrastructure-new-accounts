## EDI Preprocess

resource "aws_lambda_function" "edi_preprocess" {
  function_name = "${var.default_name}-edi-preprocess"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  timeout       = var.lambda_timeout
  image_uri     = var.edi_preprocess_image_uri
  tags          = var.tags

  vpc_config {
    subnet_ids = var.subnet_private_ids
    security_group_ids = [
      aws_security_group.stl_lambda.id
    ]
  }

  environment {
    variables = {
      ASPNETCORE_ENVIRONMENT = "${var.environment_long}"
    }
  }
}

## Remove Chars

resource "aws_lambda_function" "remove_chars" {
  function_name = "${var.default_name}-remove-chars"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  timeout       = var.lambda_timeout
  image_uri     = var.remove_chars_image_uri
  tags          = var.tags

  vpc_config {
    subnet_ids = var.subnet_private_ids
    security_group_ids = [
      aws_security_group.stl_lambda.id
    ]
  }

  environment {
    variables = {
      ASPNETCORE_ENVIRONMENT = "${var.environment_long}"
    }
  }

}


# EventBridge
resource "aws_lambda_function" "eventbridge" {
  function_name = "${var.default_name}-eventbridge"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  timeout       = var.lambda_timeout
  image_uri     = var.eventbridge_image_uri
  tags          = var.tags

  vpc_config {
    subnet_ids = var.subnet_private_ids
    security_group_ids = [
      aws_security_group.stl_lambda.id
    ]
  }

  environment {
    variables = {
      MESSAGEBROKER__MQ_USERNAME     = "${var.service}"
      MESSAGEBROKER__MQ_HOSTNAME     = "${aws_mq_broker.stl_rabbitmq.instances.0.endpoints.0}"
      MESSAGEBROKER__MQ_EXCHANGENAME = "${var.rabbitmq_username}"
      MESSAGEBROKER__MQ_PASSWORD     = "${aws_ssm_parameter.rabbitmq_password.value}"
    }
  }
}


#File Empty Check

resource "aws_lambda_function" "filecheck" {
  function_name = "${var.default_name}-fileemptycheck"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  timeout       = var.lambda_timeout
  image_uri     = var.fileemptycheck_image_uri
  tags          = var.tags

  vpc_config {
    subnet_ids = var.subnet_private_ids
    security_group_ids = [
      aws_security_group.stl_lambda.id
    ]
  }

  environment {
    variables = {
      ASPNETCORE_ENVIRONMENT = "${var.environment_long}"
    }
  }
}

## jsontocsv

resource "aws_lambda_function" "jsontocsv" {
  function_name = "${var.default_name}-jsontocsv"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  timeout       = var.lambda_timeout
  image_uri     = var.jsontocsv_image_uri
  tags          = var.tags

  vpc_config {
    subnet_ids = var.subnet_private_ids
    security_group_ids = [
      aws_security_group.stl_lambda.id
    ]
  }

  environment {
    variables = {
      ASPNETCORE_ENVIRONMENT = "${var.environment_long}"
    }
  }

}