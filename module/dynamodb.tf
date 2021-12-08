resource "aws_dynamodb_table" "sso_users" {
  name           = var.dyndb_table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = var.dyndb_read_capacity
  write_capacity = var.dyndb_write_capacity
  hash_key       = var.dyndb_hash_key
  range_key      = var.dyndb_range_key

  attribute {
    name = var.dyndb_hash_key
    type = "S"
  }

  attribute {
    name = var.dyndb_range_key
    type = "S"
  }

  tags = var.tags
}