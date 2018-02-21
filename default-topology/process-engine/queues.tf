
resource "aws_sqs_queue" "ct_event_queue" {
  name                       = "${var.application_name}-${terraform.workspace}-ct-events"
  visibility_timeout_seconds = 300
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 20

  redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.ct_event_dlq.arn}\",\"maxReceiveCount\":3}"
}

resource "aws_sqs_queue" "ct_event_dlq" {
  name                      = "${var.application_name}-${terraform.workspace}-ct-events-dlq"
  message_retention_seconds = 1209600
}

resource "aws_sqs_queue" "action_queue" {
  name                       = "${var.application_name}-${terraform.workspace}-actions"
  visibility_timeout_seconds = 300
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 20

  redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.action_dlq.arn}\",\"maxReceiveCount\":3}"
}

resource "aws_sqs_queue" "action_dlq" {
  name                      = "${var.application_name}-${terraform.workspace}-actions-dlq"
  message_retention_seconds = 1209600
}
