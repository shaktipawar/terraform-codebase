terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 5.97.0"
        }
    }
    required_version = ">= 1.11.0"
}

provider "aws" {
    alias = "mumbai"
    profile = "terraform-codebase"
    region = "ap-south-1"
    
}

provider "aws" {
    alias = "n_virginia"
    profile = "terraform-codebase"
    region = "us-east-1"
}

resource "aws_vpc" "vpc" {
    provider = aws.mumbai
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "vpc-terraform-codebase"
    }
}

resource "aws_internet_gateway" "ig" {
    depends_on = [ aws_vpc.vpc ]
    provider = aws.mumbai
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "ig-terraform-codebase"
    }
}

resource "aws_subnet" "subnet_1_private" {
    depends_on = [ aws_vpc.vpc ]
    provider = aws.mumbai
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.1.0/28"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "subnet-1-private"
    }
}

resource "aws_subnet" "subnet_2_public" {
    depends_on = [aws_vpc.vpc]
    provider = aws.mumbai
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.2.0/28"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "subnet-2-public"
    }
}

resource "aws_subnet" "subnet_3_private" {
    depends_on = [ aws_vpc.vpc ]
    provider = aws.mumbai
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.3.0/28"
    availability_zone = "ap-south-1b"
    map_public_ip_on_launch = true
    tags = {
        Name = "subnet-3-private"
    }
}

resource "aws_subnet" "subnet_4_public" {
    depends_on = [aws_vpc.vpc]
    provider = aws.mumbai
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.4.0/28"
    availability_zone = "ap-south-1b"
    map_public_ip_on_launch = true
    tags = {
        Name = "subnet-4-public"
    }
}

resource "aws_route_table" "routetable_public" {
    depends_on = [ aws_internet_gateway.ig, aws_vpc.vpc ]
    provider = aws.mumbai
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0" // Allow IPv4 Traffic
        gateway_id = aws_internet_gateway.ig.id
    }

    # route{
    #     ipv6_cidr_block = "::/0" // Allow IPv6 Traffic
    #     gateway_id = aws_internet_gateway.ig.id
    # }

    tags = {
        Name = "routetable-public"
    }
}

resource "aws_route_table_association" "routetable_association_1_public" {
    depends_on = [ aws_route_table.routetable_public, aws_subnet.subnet_2_public ]
    provider = aws.mumbai
    subnet_id = aws_subnet.subnet_2_public.id
    route_table_id = aws_route_table.routetable_public.id
}

resource "aws_route_table_association" "routetable_association_2_public" {
    depends_on = [ aws_route_table.routetable_public, aws_subnet.subnet_4_public ]
    provider = aws.mumbai
    subnet_id = aws_subnet.subnet_4_public.id
    route_table_id = aws_route_table.routetable_public.id
}

resource "aws_key_pair" "keypair" {
    provider = aws.mumbai
    key_name = "keypair-terraform-codebase"
    public_key = file(".ssh/ssh-keypair-terraform-codebase.pub")
}

resource "aws_security_group" "security_group" {
    depends_on = [ aws_vpc.vpc ]
    provider = aws.mumbai
    vpc_id = aws_vpc.vpc.id
    name = "security-group-terraform-codebase"
    description = "Security group for terraform codebase"
    tags = {
        Name = "security-group-terraform-codebase"
    }
}

resource "aws_security_group_rule" "security_group_rule_ping"{

    depends_on = [ aws_security_group.security_group ]
    type = "ingress"
    provider = aws.mumbai
    from_port = 8 // ICMP type for ping
    to_port = 0 // ICMP code for ping
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_group_id = aws_security_group.security_group.id
    description = "Allow Ping"
}

resource "aws_security_group_rule" "security_group_rule_ssh"{

    depends_on = [ aws_security_group.security_group ]
    type = "ingress"
    provider = aws.mumbai
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_group_id = aws_security_group.security_group.id
    description = "Allow SSH"
    
}

resource "aws_security_group_rule" "security_group_rule_http" {
    depends_on = [ aws_security_group.security_group ]
    type = "ingress"
    provider = aws.mumbai
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_group_id = aws_security_group.security_group.id
    description = "Allow http access"
    
}

resource "aws_security_group_rule" "security_group_rule_access_internet"{
    depends_on = [ aws_security_group.security_group ]
    type = "egress"
    provider = aws.mumbai
    from_port = 0
    to_port = 0
    protocol = "-1" // All protocols
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_group_id = aws_security_group.security_group.id
    description = "Allow Outbound Internet Access"
}

# data "template_file" "kafka_setup_server_01" {
#   template = file("/ubuntu_userdata.sh")

# }


# IAM Role for EC2 to access CloudWatch Logs
resource "aws_iam_role" "ec2_cloudwatch_role" {
    provider = aws.mumbai
    name = "ec2-cloudwatch-role"

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
  provider = aws.mumbai
  name        = "cloudwatch-logs-policy"
  description = "Policy to allow EC2 to write logs to CloudWatch"
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

# Attach the policy to the IAM Role
resource "aws_iam_role_policy_attachment" "attach_cloudwatch_policy" {
    provider = aws.mumbai
    role       = aws_iam_role.ec2_cloudwatch_role.name
    policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}

# Create an IAM Instance Profile for the EC2 instance
resource "aws_iam_instance_profile" "ec2_instance_profile" {
    provider = aws.mumbai
    name = "ec2-instance-profile"
    role = aws_iam_role.ec2_cloudwatch_role.name
}

resource "aws_cloudwatch_log_group" "userdata_log_group" {
    provider = aws.mumbai
    name = "/ec2/terraform-codebase/userdata"
    retention_in_days = 7 # Optional: Set log retention period
        tags = {
            Name = "Terraform Codebase Userdata Logs"
        }
}

resource "aws_instance" "ec2_1" {
    depends_on = [ 
        aws_iam_role_policy_attachment.attach_cloudwatch_policy,
        aws_vpc.vpc, 
        aws_internet_gateway.ig,  
        aws_security_group.security_group 
    ]
    provider = aws.mumbai
    #ami = "ami-062f0cc54dbfd8ef1" // Amazon Linux 2 AMI
    ami = "ami-0e35ddab05955cf57" // Ubuntu Server 24.04 LTS
    instance_type = "t2.micro"
    key_name = aws_key_pair.keypair.key_name
    subnet_id = aws_subnet.subnet_2_public.id
    vpc_security_group_ids = [aws_security_group.security_group.id]
    #user_data = data.template_file.kafka_setup_server_01.rendered
    user_data = file("/ubuntu_userdata.sh")
    iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
    tags = {
        Name = "ec2-1-terraform-codebase"
    }
}