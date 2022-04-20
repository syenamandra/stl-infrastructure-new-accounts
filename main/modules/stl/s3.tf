resource "aws_s3_bucket" "stl-cacentral" {
  provider      = aws
  bucket        = var.s3_bucket_name
  force_destroy = false

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "S3PolicyId1",
    "Statement": [
        {
            "Sid": "IPAllow",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::${var.s3_bucket_name}/*",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": ${jsonencode(var.trusted_networks)}
                }
            }
        }
    ]
}
POLICY


  tags = var.tags
}
