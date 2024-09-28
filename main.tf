provider "aws" {
  region = "us-east-1"  # Set your AWS region
}

# Create an S3 bucket to store logs and Lambda ZIPs
resource "aws_s3_bucket" "incident_logs" {
  bucket = "incident-response-logs"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# Upload the Lambda ZIP file to S3 automatically
resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.incident_logs.bucket
  key    = "incident-handler/incident_handler.zip"  # Folder structure within the bucket
  source = "C:/Users/USER/Desktop/aws2024/incident-response-system/incident_handler.zip"  # Local path to the ZIP file
}

# Enable GuardDuty
resource "aws_guardduty_detector" "gd" {
  enable = true
}

# Create a CloudWatch Alarm for unauthorized API calls
resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls" {
  alarm_name          = "UnauthorizedAPICallsAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnauthorizedAPICalls"
  namespace           = "AWS/GuardDuty"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"

  alarm_actions = [
    aws_sns_topic.incident_response.arn
  ]
}

# Create an SNS topic to trigger Lambda
resource "aws_sns_topic" "incident_response" {
  name = "incident-response-sns"
}

# Create a Lambda function for automated incident response, pulling the ZIP from S3
resource "aws_lambda_function" "incident_handler" {
  function_name = "incident_handler_lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"  # Adjust based on your actual function names
  runtime       = "python3.9"
  
  # Reference the S3 object for Lambda code
  s3_bucket = aws_s3_bucket.incident_logs.bucket
  s3_key    = aws_s3_object.lambda_zip.key

  environment {
    variables = {
      SNS_TOPIC = aws_sns_topic.incident_response.arn
    }
  }
}

# SNS subscription to Lambda function
resource "aws_sns_topic_subscription" "incident_response_subscription" {
  topic_arn = aws_sns_topic.incident_response.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.incident_handler.arn
}

# Lambda permission to allow SNS to invoke it
resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.incident_handler.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.incident_response.arn
}

# Lambda execution role
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonGuardDutyFullAccess",
    "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
  ]
}

# Create Step Functions for automated workflows
resource "aws_sfn_state_machine" "incident_workflow" {
  name     = "IncidentWorkflow"
  role_arn = aws_iam_role.lambda_exec_role.arn

  definition = jsonencode({
    "Comment": "Incident response workflow",
    "StartAt": "ProcessIncident",
    "States": {
      "ProcessIncident": {
        "Type": "Task",
        "Resource": aws_lambda_function.incident_handler.arn,
        "End": true
      }
    }
  })
}
