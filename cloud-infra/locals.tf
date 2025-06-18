locals {
  # Prefixes for resource names
  prefix = {
    security_group       = "sec-grp"
    security_group_rule  = "sec-grp-rule"
    vpc                  = "vpc"
    key_pair             = "kp"
    subnet               = "subnet"
    internet_gateway     = "igw"
    nat_gateway          = "nat-gw"
    elastic_ip           = "eip"
    public_route_table   = "public-rt"
    private_route_table  = "private-rt"
    ec2                  = "ec2"
    cloudwatch           = "cw"
    ec2-instance-profile = "ec2-inst-prof"
    cloudwatch_log_group = "cw-log-grp"
    target_group         = "tg"
    load_balancer        = "lb"
  }

  # Default tags to be applied to all resources
  default_tags = {
    Environment = terraform.workspace
    Project     = var.general_info.project
    Created_On  = time_static.now.rfc3339
    Created_By  = var.general_info.created_by
  }

  # General reusable tag generator
  generate_tags = merge(
    local.default_tags, {
      for prefix_key, prefix_value in local.prefix : prefix_key => {
      Name = "${terraform.workspace}-${var.general_info.project}-${prefix_value}"
      }
    }
  )

  vpc_tags = local.generate_tags["vpc"]
  internet_gateway_tags = local.generate_tags["internet_gateway"]
  elastic_ip_tags = local.generate_tags["elastic_ip"]
  nat_gateway_tags = local.generate_tags["nat_gateway"]
  public_route_table_tags = local.generate_tags["public_route_table"]
  private_route_table_tags = local.generate_tags["private_route_table"]
  cloudwatch_logs_group_tags = local.generate_tags["cloudwatch_log_group"]
  target_group_tags = local.generate_tags["target_group"]
  load_balancer_tags = local.generate_tags["load_balancer"]


  # Key pair configuration, including the name and public key to be used for SSH access
  key_pair = {
    key_name   = "${terraform.workspace}-${var.general_info.project}-${local.prefix["key_pair"]}"
    public_key = file(var.key_path)
    tags = local.generate_tags["key_pair"]
  }
  
  instance_ids = [
    for instance in module.ec2-setup.ec2_details : instance.id
  ]

  listener_certificate_arn = data.aws_acm_certificate.issued.arn

  availability_zones = data.aws_availability_zones.available.names
  
  unique_subnets_per_az = [
    for az in data.aws_availability_zones.available.names :
    # Filter subnets to get one subnet per availability zone, handle empty collections gracefully
    [for subnet in values(module.cloud-infra.subnet_details) : subnet.id if subnet.availability_zone == az][0]
    if length([for subnet in values(module.cloud-infra.subnet_details) : subnet.id if subnet.availability_zone == az]) > 0
  ]

  iam_policy = {
    cloudwatch_role_name              = "${terraform.workspace}-${var.general_info.project}-${local.prefix["cloudwatch"]}-role"
    cloudwatch_log_policy_name        = "${terraform.workspace}-${var.general_info.project}-${local.prefix["cloudwatch"]}-policy"
    cloudwatch_log_policy_description = "Policy for EC2 instance to send logs to CloudWatch"
  }

  log_group_name = "${terraform.workspace}-${var.general_info.project}-${local.prefix["cloudwatch"]}-loggroup"
  
  instance_profile_name = "${terraform.workspace}-${var.general_info.project}-${local.prefix["ec2-instance-profile"]}"
  
  hosted_zone_id        = data.aws_route53_zone.hosted_zone.id

}

