resource "aws_sqs_queue" "sqs" {
  name              = "${var.tags["Environment"]}-alerts-queue"
  kms_master_key_id = aws_kms_alias.sqs_kms_key.id

  tags = var.tags
}

resource "aws_sqs_queue_policy" "sqs" {
  queue_url = aws_sqs_queue.sqs.id
  policy    = data.template_file.sqs.rendered
}