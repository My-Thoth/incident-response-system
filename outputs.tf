output "s3_bucket" {
  description = "S3 bucket for incident logs"
  value       = aws_s3_bucket.incident_logs.bucket
}

output "lambda_function" {
  description = "Incident handler Lambda function"
  value       = aws_lambda_function.incident_handler.arn
}

output "state_machine" {
  description = "State machine for incident workflow"
  value       = aws_sfn_state_machine.incident_workflow.arn
}
