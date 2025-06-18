
resource "aws_iam_role_policy_attachment" this {
  role       = var.cloudwatch_role_name      
  policy_arn = var.iam_log_policy_arn 
}

resource "aws_cloudwatch_log_group" this {
  name              = var.cloudwatch_log_group_name                            
  retention_in_days = var.cloudwatch_log_group_retention_days 
  tags              = var.cloudwatch_log_group_tags
}

