resource "aws_kms_key" "cw_log_groups_kms_key" {
  description         = "KMS Key used to encrypt Cloudwatch log groups."
  enable_key_rotation = var.enable_key_rotation
  policy              = data.template_file.cw_log_groups_kms_policy.rendered

  tags = var.tags
}

resource "aws_kms_alias" "cw_log_groups_kms_key" {
  name          = "alias/${var.tags["Environment"]}-cw-log-groups-key"
  target_key_id = aws_kms_key.cw_log_groups_kms_key.key_id
}

resource "aws_kms_key" "sqs_kms_key" {
  description         = "KMS Key used to encrypt SQS queues."
  enable_key_rotation = var.enable_key_rotation
  policy              = data.template_file.sqs_kms_policy.rendered

  tags = var.tags
}

resource "aws_kms_alias" "sqs_kms_key" {
  name          = "alias/${var.tags["Environment"]}-sqs-key"
  target_key_id = aws_kms_key.sqs_kms_key.key_id
}