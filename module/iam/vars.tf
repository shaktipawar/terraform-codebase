variable "cloudwatch_role_name" {
  type        = string
  description = "Name of the IAM role for CloudWatch logging."
}

variable "cloudwatch_log_policy_name" {
  type        = string
  description = "Name of the IAM policy for CloudWatch logging."
}

variable "cloudwatch_log_policy_description" {
  type        = string
  description = "Description for the CloudWatch logging policy."
}
