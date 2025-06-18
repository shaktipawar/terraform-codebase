variable "ec2"{
    type = list(object({
        ami                    = string
        instance_type          = string
        key_name               = string
        subnet_id              = string
        vpc_security_group_ids = list(string)
        user_data              = string # User data script
        iam_instance_profile_name   = string
        tags                   = map(string)
    }))
    description = "Configuration for the EC2 instance including AMI, instance type, key name, subnet ID, security groups, user data, IAM profile, and tags."
}