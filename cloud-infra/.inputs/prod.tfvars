general_info = {
  project     = "cloudcake"
  created_by  = "terraform"
  region = "us-east-1"
}

vpc = {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = {}
}

key_path = ".ssh/prod.pub"

subnets = [
  {
    cidr_block        = "10.0.1.0/24",
    availability_zone = "us-east-1a",
    is_public         = true
  },
  {
    cidr_block        = "10.0.1.0/24",
    availability_zone = "us-east-1a",
    is_public         = false
  },
  {
    cidr_block        = "10.0.2.0/24",
    availability_zone = "us-east-1b",
    is_public         = false
  },
  {
    cidr_block        = "10.0.3.0/24",
    availability_zone = "us-east-1c",
    is_public         = false
  },
]

route_table_public = {
  cidr_block      = "0.0.0.0/0"
  ipv4_cidr_block = "::/0"
}

route_table_private = {
  cidr_block      = "0.0.0.0/0"
  ipv4_cidr_block = "::/0"
}

ec2 = [{
  ami           = "ami-0e35ddab05955cf57"
  instance_type = "t2.micro"
  subnet_type = "public"
  user_data = "./userdata-scripts/ubuntu_webserver.sh"
},
{
  ami           = "ami-0e35ddab05955cf57"
  instance_type = "t2.micro"
  subnet_type = "public"
  user_data = "./userdata-scripts/ubuntu_webserver.sh"
},
{
  ami           = "ami-0e35ddab05955cf57"
  instance_type = "t2.micro"
  subnet_type = "private"
  user_data = "./userdata-scripts/ubuntu_webserver.sh"
},
{
  ami           = "ami-0e35ddab05955cf57"
  instance_type = "t2.micro"
  subnet_type = "private"
  user_data = "./userdata-scripts/ubuntu_webserver.sh"
},
{
  ami           = "ami-0e35ddab05955cf57"
  instance_type = "t2.micro"
  subnet_type = "private"
  user_data = "./userdata-scripts/ubuntu_webserver.sh"
},
{
  ami           = "ami-0e35ddab05955cf57"
  instance_type = "t2.micro"
  subnet_type = "private"
  user_data = "./userdata-scripts/ubuntu_webserver.sh"
}]


cloudwatch_log_group_retention_days = 7

target_group = {
  healthy_threshold   = "3"
  interval            = "20"
  unhealthy_threshold = "2"
  timeout             = "10"
  path                = "/"
  health_port         = "80"
}

domain_name = "elfsstudio.com"
a_records = ["", "www", "prod"]