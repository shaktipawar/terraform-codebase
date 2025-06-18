resource "aws_instance" this {
    for_each = {
        for idx, ec2_item in var.ec2 : idx => ec2_item
    }
    ami = each.value.ami #"ami-0e35ddab05955cf57" // Ubuntu Server 24.04 LTS // #ami = "ami-062f0cc54dbfd8ef1" // Amazon Linux 2 AMI
    instance_type = each.value.instance_type #"t2.micro"
    key_name = each.value.key_name
    subnet_id = each.value.subnet_id
    vpc_security_group_ids = each.value.vpc_security_group_ids
    user_data = each.value.user_data
    iam_instance_profile = each.value.iam_instance_profile_name
    tags = each.value.tags
}


