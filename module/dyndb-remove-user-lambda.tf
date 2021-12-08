data "archive_file" "dyndb_remove_user" {
  type        = "zip"
  output_path = "dyndb_remove_user.zip"
  source_file = "${path.module}/python_scripts/dyndb_remove_user.py"
}

resource "aws_lambda_function" "dyndb_remove_user" {
  function_name    = "${var.tags["Environment"]}-dynamodb-remove-user"
  description      = "This function is used to update the SSOUsersList DynamoDB table when an SSO user is deleted."
  handler          = "dyndb_remove_user.lambda_handler"
  filename         = data.archive_file.dyndb_remove_user.output_path
  source_code_hash = filebase64sha256(data.archive_file.dyndb_remove_user.output_path)
  role             = aws_iam_role.dyndb_lambdas_role.arn
  runtime          = var.lambdas_runtime
  timeout          = var.lambdas_timeout
  memory_size      = var.lambdas_memory_size

  environment {
    variables = {
      DYNAMODB_TABLE       = aws_dynamodb_table.sso_users.name
      SSO_IDENTITYSTORE_ID = tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0]
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.dyndb_lambdas_policy,
    aws_cloudwatch_log_group.dyndb_remove_user,
  ]

  tags = var.tags
}
