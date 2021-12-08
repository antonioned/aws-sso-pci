
variable "tags" {
  type = map(string)
}

variable "region" {
}

variable "lambdas_runtime" {
  description = "The runtime environment for the Lambda functions."
  type        = string
}

variable "lambdas_timeout" {
  description = "The Lambda functions timeout."
  type        = string
}

variable "lambdas_memory_size" {
  description = "The Lambda functions memory size."
  type        = string
}

variable "cw_retention_in_days" {
  type        = number
  description = "The number in days for the retention of CW log group logs."
}

variable "lambdas_cw_schedule_expression" {
  type        = string
  description = "The rate expression on when to trigger the SSO lambda functions."
}

variable "dyndb_table_name" {
  type        = string
  description = "The name of the DynamoDB table used to store SSO users."
}

variable "dyndb_read_capacity" {
  type        = string
  description = "The RCU for the DynamoDB table."
}

variable "dyndb_write_capacity" {
  type        = string
  description = "The WCU for the DynamoDB table."
}

variable "dyndb_hash_key" {
  type        = string
  description = "The partition (hash( key for the SSO dynamodb table."
}

variable "dyndb_range_key" {
  type        = string
  description = "The sort (range) key for the SSO dynamodb table."
}

variable "assume_lambda_role_policy" {
}

variable "enable_key_rotation" {
  type        = bool
  description = "Whether KMS key rotation is enabled."
}
