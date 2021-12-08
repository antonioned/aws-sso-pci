resource "aws_cloudwatch_log_group" "user_inactivity" {
  name              = "/aws/lambda/${var.tags["Environment"]}-sso-user-inactivity"
  kms_key_id        = aws_kms_key.cw_log_groups_kms_key.arn
  retention_in_days = var.cw_retention_in_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "password_expiration" {
  name              = "/aws/lambda/${var.tags["Environment"]}-sso-password-expiration"
  kms_key_id        = aws_kms_key.cw_log_groups_kms_key.arn
  retention_in_days = var.cw_retention_in_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "dyndb_add_user" {
  name              = "/aws/lambda/${var.tags["Environment"]}-dynamodb-add-user"
  kms_key_id        = aws_kms_key.cw_log_groups_kms_key.arn
  retention_in_days = var.cw_retention_in_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "dyndb_remove_user" {
  name              = "/aws/lambda/${var.tags["Environment"]}-dynamodb-remove-user"
  kms_key_id        = aws_kms_key.cw_log_groups_kms_key.arn
  retention_in_days = var.cw_retention_in_days

  tags = var.tags
}
