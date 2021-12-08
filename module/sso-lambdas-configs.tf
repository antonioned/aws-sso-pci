### IAM configs ###

# The IAM role for the SSO Lambda functions
resource "aws_iam_role" "sso_lambdas_role" {
  name               = "${var.tags["Environment"]}-sso-lambdas-role"
  assume_role_policy = var.assume_lambda_role_policy
  description        = "This role is used by the SSO Lambda functions."

  tags = var.tags
}

# IAM policy allowing SSO Lambdas IAM role access to AWS services
resource "aws_iam_policy" "sso_lambdas_policy" {
  name        = "${var.tags["Environment"]}-sso-lambdas-services-access"
  description = "This policy allows the SSO Lambdas role access to AWS services."
  path        = "/"
  policy      = data.template_file.sso_lambdas_policy.rendered

  tags = var.tags
}

# Attach IAM policy for accessing AWS services
resource "aws_iam_role_policy_attachment" "sso_lambdas_policy" {
  role       = aws_iam_role.sso_lambdas_role.name
  policy_arn = aws_iam_policy.sso_lambdas_policy.arn
}

### Eventbridge configs ###

# User inactivity Lambda #
resource "aws_cloudwatch_event_rule" "sso_lambda_inactivity" {
  name                = "SSOLambdaUserInactivityEventRule"
  description         = "Triggers the SSO user-inactivity Lambda function."
  schedule_expression = var.lambdas_cw_schedule_expression

  depends_on = [
    aws_lambda_function.user_inactivity,
  ]

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "sso_lambda_inactivity" {
  arn  = aws_lambda_function.user_inactivity.arn
  rule = aws_cloudwatch_event_rule.sso_lambda_inactivity.name

  depends_on = [
    aws_lambda_function.user_inactivity,
  ]
}

resource "aws_lambda_permission" "invoke_user_inactivity_lambda" {
  statement_id  = "AllowExecutionFromEventbridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_inactivity.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sso_lambda_inactivity.arn

  depends_on = [
    aws_lambda_function.user_inactivity,
  ]
}

# Password expiration Lambda #
resource "aws_cloudwatch_event_rule" "sso_lambda_password_expiration" {
  name                = "SSOLambdaPasswordExpirationEventRule"
  description         = "Trigger the SSO password-expiration Lambda function."
  schedule_expression = var.lambdas_cw_schedule_expression

  depends_on = [
    aws_lambda_function.password_expiration,
  ]

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "sso_lambda_password_expiration" {
  arn  = aws_lambda_function.password_expiration.arn
  rule = aws_cloudwatch_event_rule.sso_lambda_password_expiration.name

  depends_on = [
    aws_lambda_function.password_expiration,
  ]
}

resource "aws_lambda_permission" "invoke_password_expiration_lambda" {
  statement_id  = "AllowExecutionFromEventbridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.password_expiration.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sso_lambda_password_expiration.arn

  depends_on = [
    aws_lambda_function.password_expiration,
  ]
}