
variable "profile" {
  default = "klinec"
  type    = string
}

variable "region" {
  default = "eu-west-1"
  type    = string
}

variable "tags" {
  type = map(any)

  default = {
    Environment = "env"
    CostCenter  = "cost"
  }
}

variable "create_lambda_resources" {
  type        = bool
  description = "Whether to create the SSO Lambda resources - true in root AWS account."
  default     = true
}

variable "lambdas_runtime" {
  description = "The runtime environment for the Lambda functions."
  type        = string
  default     = "python3.8"
}

variable "lambdas_timeout" {
  description = "The Lambda functions timeout."
  type        = number
  default     = 60
}

variable "lambdas_memory_size" {
  description = "The Lambda functions memory size."
  type        = number
  default     = 128
}

variable "cw_retention_in_days" {
  type        = number
  description = "The number in days for the retention of CW log group logs."
  default     = 180
}

variable "lambdas_cw_schedule_expression" {
  type        = string
  description = "The rate expression on when to trigger the SSO lambda functions."
  default     = "rate(1 day)"
}

variable "dyndb_table_name" {
  type        = string
  description = "The name of the DynamoDB table used to store SSO users."
  default     = "SSOUsersList"
}

variable "dyndb_read_capacity" {
  type        = number
  description = "The RCU for the DynamoDB table."
  default     = 5
}

variable "dyndb_write_capacity" {
  type        = number
  description = "The WCU for the DynamoDB table."
  default     = 5
}

variable "dyndb_hash_key" {
  type        = string
  description = "The partition (hash( key for the SSO dynamodb table."
  default     = "UserId"
}

variable "dyndb_range_key" {
  type        = string
  description = "The sort (range) key for the SSO dynamodb table."
  default     = "Username"
}

variable "enable_key_rotation" {
  type        = bool
  description = "Whether KMS key rotation is enabled."
  default     = true
}