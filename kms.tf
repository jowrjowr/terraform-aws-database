resource "aws_kms_key" "database" {
  description             = "${var.project} ${var.environment} database KMS master key"
  deletion_window_in_days = 30
  tags = {
    Name        = "${var.project}_${var.environment}"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }
}

resource "aws_kms_alias" "database" {
  name          = "alias/${var.project}_${var.environment}"
  target_key_id = aws_kms_key.database.key_id
}
