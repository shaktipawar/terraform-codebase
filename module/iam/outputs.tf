output "iam_policy_arn" {
  value = aws_iam_policy.cloudwatch_logs_policy.arn
}
 

# output "iam_role_name" {
#   value = aws_iam_role.ec2_cloudwatch_role.name
# }
