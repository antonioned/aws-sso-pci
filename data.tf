data "aws_caller_identity" "current" {
}

data "template_file" "assume_lambda_role_policy" {
  template = file("${path.module}/iam_policies/assume_lambda_role_policy.json")
}