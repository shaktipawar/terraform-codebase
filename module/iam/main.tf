# IAM Role for EC2 to access CloudWatch Logs
resource "aws_iam_role" "ec2_cloudwatch_role" {

  name = var.cloudwatch_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy to allow CloudWatch Logs access
resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = var.cloudwatch_log_policy_name
  description = var.cloudwatch_log_policy_description
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

