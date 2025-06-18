variable "instance_profile_name" {
  type        = string
  description = "Name of the IAM instance profile."
}

variable "cloudwatch_role_name" {
  type        = string
  description = "Name of the IAM role for CloudWatch logging."
}