variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "S3 bucket name to store incident logs"
  default     = "incident-response-logs"
}
