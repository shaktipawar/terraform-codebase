# Create an IAM Instance Profile for the EC2 instance
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = var.instance_profile_name #"ec2-instance-profile"
  role = var.cloudwatch_role_name  #aws_iam_role.ec2_cloudwatch_role.name
}
