data "aws_caller_identity" "current" {
}

data "aws_ssoadmin_instances" "sso" {
}

# Gives SSO Lambda roles access to services
data "template_file" "sso_lambdas_policy" {
  template = file("${path.module}/iam_policies/sso_lambdas_policy.json")

  vars = {
    region             = var.region
    aws_account_id     = data.aws_caller_identity.current.account_id
    dynamodb_table_arn = aws_dynamodb_table.sso_users.arn
    sqs_queue_arn      = aws_sqs_queue.sqs.arn
    sqs_kms_key_arn    = aws_kms_key.sqs_kms_key.arn
  }
}

# Gives DynamoDB Lambda roles access to services
data "template_file" "dyndb_lambdas_policy" {
  template = file("${path.module}/iam_policies/dyndb_lambdas_policy.json")

  vars = {
    region             = var.region
    aws_account_id     = data.aws_caller_identity.current.account_id
    dynamodb_table_arn = aws_dynamodb_table.sso_users.arn
  }
}

data "template_file" "sqs" {
  template = file("${path.module}/iam_policies/sqs_policy.json")

  vars = {
    aws_account_id = data.aws_caller_identity.current.account_id
    sqs_queue_arn  = aws_sqs_queue.sqs.arn
  }
}

data "template_file" "cw_log_groups_kms_policy" {
  template = file("${path.module}/iam_policies/cw_log_groups_kms_policy.json")
  vars = {
    aws_account_id = data.aws_caller_identity.current.account_id
  }
}

data "template_file" "sqs_kms_policy" {
  template = file("${path.module}/iam_policies/sqs_kms_policy.json")
  vars = {
    aws_account_id = data.aws_caller_identity.current.account_id
  }
}
