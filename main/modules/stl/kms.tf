resource "aws_kms_key" "stl" {
  description = "${var.service}/${var.environment}"
  tags        = var.tags
}

resource "aws_kms_alias" "stl" {
  name          = "alias/${var.default_name}"
  target_key_id = aws_kms_key.stl.key_id
}
