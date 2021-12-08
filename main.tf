module "sso" {
  source = "./module"

  region                         = var.region
  enable_key_rotation            = var.enable_key_rotation
  cw_retention_in_days           = var.cw_retention_in_days
  lambdas_cw_schedule_expression = var.lambdas_cw_schedule_expression
  lambdas_runtime                = var.lambdas_runtime
  lambdas_timeout                = var.lambdas_timeout
  lambdas_memory_size            = var.lambdas_memory_size
  dyndb_table_name               = var.dyndb_table_name
  dyndb_read_capacity            = var.dyndb_read_capacity
  dyndb_write_capacity           = var.dyndb_write_capacity
  dyndb_hash_key                 = var.dyndb_hash_key
  dyndb_range_key                = var.dyndb_range_key
  assume_lambda_role_policy      = data.template_file.assume_lambda_role_policy.rendered

  tags = merge(
    var.tags,
    {
      "AWSService" = "SSO"
    },
  )
}