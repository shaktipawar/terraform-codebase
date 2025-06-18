variable "cloudwatch_role_name" {
  type        = string
  description = "Name of the IAM role for CloudWatch logging."
}

variable "cloudwatch_log_group_name" {
  type        = string
  description = "Name of the CloudWatch log group."
}

variable "cloudwatch_log_group_retention_days" {
  type        = number
  description = "Retention days for the CloudWatch log group."
}

variable "cloudwatch_log_group_tags" {
  type        = map(string)
  description = "Tags for the CloudWatch log group."
}

variable "iam_log_policy_arn" {
  type        = string
  description = "ARN of the IAM policy for CloudWatch logging."
}