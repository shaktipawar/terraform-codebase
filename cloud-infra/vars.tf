variable "general_info" {
  type = object({
    project    = string
    created_by = string
    region     = string
  })
}

variable "vpc" {
  type = object({
    cidr_block           = string
    instance_tenancy     = string
    enable_dns_support   = bool
    enable_dns_hostnames = bool
    tags                 = map(string)
  })
}

variable "key_path" {
  type        = string
  description = "Path to the public key file for SSH access."
}

variable "subnets" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
    is_public         = bool
  }))
  description = "List of subnets with CIDR blocks and public/private flag"
}

variable "route_table_public" {
  type = object({
    cidr_block      = string
    ipv4_cidr_block = string
  })
  description = "Public route table configuration with CIDR blocks"
}

variable "route_table_private" {
  type = object({
    cidr_block      = string
    ipv4_cidr_block = string
  })
  description = "Public route table configuration with CIDR blocks"
}

variable "ec2" {
  type = list(object({
    ami           = string
    instance_type = string
    subnet_type = string # "public" or "private"
    user_data = string
  }))
  description = "Configuration for the EC2 instance including AMI, instance type, key name, subnet ID, security groups, user data, IAM profile, and tags."
}

variable "cloudwatch_log_group_retention_days" {
  type        = number
  description = "Retention days for the CloudWatch log group."
}

variable "target_group" {
  type = object({
    healthy_threshold   = string
    interval            = string
    unhealthy_threshold = string
    timeout             = string
    path                = string
  })
  description = "List of target groups with their configurations"
}

variable "domain_name" {
  description = "Domain name for the Route 53 records"
  type        = string
}

variable "a_records" {
  description = "List of A records to create in Route 53"
  type        = list(string)
}