# Create an IAM Instance Profile for the EC2 instance
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = var.instance_profile_name
  role = var.cloudwatch_role_name
}
