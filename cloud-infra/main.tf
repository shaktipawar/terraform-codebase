resource "time_static" "now" {}

module "cloud-infra" {

  source = "../module/vpc"

  # VPC configuration parameters
  vpc = {
    cidr_block           = var.vpc.cidr_block
    instance_tenancy     = var.vpc.instance_tenancy
    enable_dns_support   = var.vpc.enable_dns_support
    enable_dns_hostnames = var.vpc.enable_dns_hostnames
    tags = local.vpc_tags
  }

  # Key Pair configuration parameters for SSH access
  key_pair      = local.key_pair

  # Subnet configuration parameters
  subnets = [
    for idx, subnet in var.subnets : {
      vpc_id                  = module.cloud-infra.vpc_id
      cidr_block              = subnet.cidr_block
      availability_zone       = subnet.availability_zone
      map_public_ip_on_launch = subnet.is_public
      tags = merge(
        local.default_tags,
        { Name = "${terraform.workspace}-${var.general_info.project}-${local.prefix["subnet"]}-${subnet.is_public ? "public" : "private"}-${idx + 1}" },
        { Type = "${subnet.is_public ? "public" : "private"}" }
      )
    }
  ]

  # Internet Gateway configuration parameters
  internet_gateway = {
    vpc_id = module.cloud-infra.vpc_id
    tags = local.internet_gateway_tags
  }

  # Elastic IPs configuration parameters
  elastic_ips = {
      tags = local.elastic_ip_tags
  }
  
  #NAT Gateway configuration parameters
  nat_gateway = {
    allocation_id = module.cloud-infra.elastic_ip_ids
    subnet_id     = module.cloud-infra.public_subnet_ids[0]
    tags = local.nat_gateway_tags
  }

  # Public and Private Route Tables configuration parameters
  route_table_public = {
    vpc_id              = module.cloud-infra.vpc_id
    cidr_block          = var.route_table_public.cidr_block      
    ipv6_cidr_block     = var.route_table_public.ipv4_cidr_block 
    internet_gateway_id = module.cloud-infra.internet_gateway_id
    tags = local.public_route_table_tags
  }
  
  route_table_private = {
    vpc_id          = module.cloud-infra.vpc_id
    cidr_block      = var.route_table_private.cidr_block      
    ipv6_cidr_block = var.route_table_private.ipv4_cidr_block 
    nat_gateway_id  = module.cloud-infra.nat_gateway_ids 
    tags = local.private_route_table_tags
  }

  route_table_associations = concat([
    # Associate public subnets with public route tables
    for idx, subnet_id in module.cloud-infra.public_subnet_ids : {
      subnet_id      = subnet_id
      route_table_id = module.cloud-infra.public_route_table_ids
    }
    ], [
    # Associate private subnets with private route tables
    for idx, subnet_id in module.cloud-infra.private_subnet_ids : {
      subnet_id      = subnet_id
      route_table_id = module.cloud-infra.private_route_table_ids
    }
  ])
}

module "security-group-web-access" {
  source                     = "../module/security-group"
  depends_on                 = [module.cloud-infra]
  vpc_id                     = module.cloud-infra.vpc_id
  security_group_name        = "${local.prefix["security_group"]}-web-access"
  security_group_description = "Security group created for http and https access"
  tags = merge(
    local.default_tags,
    { Name = "${terraform.workspace}-${var.general_info.project}-${local.prefix["security_group"]}-web-access" }
  )

  security_group_rules_ingress = {
    "http" = {
      security_group_id = module.security-group-web-access.security_group_details.id
      cidr_ipv4         = "0.0.0.0/0"
      from_port         = 80
      to_port           = 80
      ip_protocol       = "tcp"
      tags = merge(local.default_tags, {
        Name = "${terraform.workspace}-${var.general_info.project}-${local.prefix["security_group_rule"]}-http-ipv4"
      })
    },
    "http_ipv6" = {
      security_group_id = module.security-group-web-access.security_group_details.id
      is_ipv4           = false
      cidr_ipv6         = "::/0"
      from_port         = 80
      to_port           = 80
      ip_protocol       = "tcp"
      tags = merge(local.default_tags, {
        Name = "${terraform.workspace}-${var.general_info.project}-${local.prefix["security_group_rule"]}-http-ipv6"
      })
    },
    "https" = {
      security_group_id = module.security-group-web-access.security_group_details.id
      cidr_ipv4         = "0.0.0.0/0"
      from_port         = 443
      to_port           = 443
      ip_protocol       = "tcp"
      tags = merge(local.default_tags, {
        Name = "${terraform.workspace}-${var.general_info.project}-${local.prefix["security_group_rule"]}-https-ipv4"
      })
    },
    "https_ipv6" = {
      security_group_id = module.security-group-web-access.security_group_details.id
      is_ipv4           = false
      cidr_ipv6         = "::/0"
      from_port         = 443
      to_port           = 443
      ip_protocol       = "tcp"
      tags = merge(local.default_tags, {
        Name = "${terraform.workspace}-${var.general_info.project}-${local.prefix["security_group_rule"]}-https-ipv6"
      })
    }
  }

  security_group_rules_egress = {}
}

module "security-group-ssh-access" {
  source                     = "../module/security-group"
  depends_on                 = [module.cloud-infra]
  vpc_id                     = module.cloud-infra.vpc_id
  security_group_name        = "${local.prefix["security_group"]}-ssh-access"
  security_group_description = "Security group created for ssh access"
  tags = merge(local.default_tags, {
    Name = "${terraform.workspace}-${var.general_info.project}-${local.prefix["security_group"]}-ssh-access"
  })

  security_group_rules_ingress = {
    "ssh" = {
      security_group_id = module.security-group-ssh-access.security_group_details.id
      cidr_ipv4         = "0.0.0.0/0"
      from_port         = 22
      to_port           = 22
      ip_protocol       = "tcp"
      tags = merge(local.default_tags, {
        Name = "${terraform.workspace}-${var.general_info.project}-${local.prefix["security_group_rule"]}-ssh-ipv4"
      })
    },
    "ssh_ipv6" = {
      security_group_id = module.security-group-ssh-access.security_group_details.id
      is_ipv4           = false
      cidr_ipv6         = "::/0"
      from_port         = 22
      to_port           = 22
      ip_protocol       = "tcp"
      tags = merge(local.default_tags, {
        Name = "${terraform.workspace}-${var.general_info.project}-${local.prefix["security_group_rule"]}-ssh-ipv6"
      })
    }
  }

  security_group_rules_egress = {}
}

module "security-group-outbound-access" {
  source                     = "../module/security-group"
  depends_on                 = [module.cloud-infra]
  vpc_id                     = module.cloud-infra.vpc_id
  security_group_name        = "${local.prefix["security_group"]}-outbound-access"
  security_group_description = "Security group created for outbound access"
  tags = merge(local.default_tags, {
    Name = "${terraform.workspace}-${var.general_info.project}-${local.prefix["security_group"]}-outbound-access"
  })

  security_group_rules_ingress = {}

  security_group_rules_egress = {
    "open-all" = {
      security_group_id = module.security-group-outbound-access.security_group_details.id
      cidr_ipv4         = "0.0.0.0/0"
      from_port         = 0
      to_port           = 0
      ip_protocol       = "-1" # All traffic
      tags = merge(local.default_tags, {
        Name = "${terraform.workspace}-${var.general_info.project}-${local.prefix["security_group_rule"]}-outbound-ipv4"
      })
    },
    "open-all-ipv6" = {
      security_group_id = module.security-group-outbound-access.security_group_details.id
      is_ipv4           = false
      cidr_ipv6         = "::/0"
      from_port         = 0
      to_port           = 0
      ip_protocol       = "-1" # All Traffic
      tags = merge(local.default_tags, {
        Name = "${terraform.workspace}-${var.general_info.project}-${local.prefix["security_group_rule"]}-outbound-ipv6"
      })
    }
  }
}

module "iam_policy" {
  source = "../module/iam"
  cloudwatch_role_name              = local.iam_policy.cloudwatch_role_name
  cloudwatch_log_policy_name        = local.iam_policy.cloudwatch_log_policy_name
  cloudwatch_log_policy_description = local.iam_policy.cloudwatch_log_policy_description
}

module "cloudwatch_logs" {
  source     = "../module/cloudwatch-logs"
  depends_on = [module.iam_policy]
  cloudwatch_role_name                = local.iam_policy.cloudwatch_role_name
  cloudwatch_log_group_name           = local.log_group_name
  cloudwatch_log_group_retention_days = var.cloudwatch_log_group_retention_days
  iam_log_policy_arn                  = module.iam_policy.iam_policy_arn
  cloudwatch_log_group_tags = local.cloudwatch_logs_group_tags
}

module "instance_profile" {
  source     = "../module/instance-profile"
  depends_on = [module.iam_policy, module.cloudwatch_logs]
  instance_profile_name = local.instance_profile_name
  cloudwatch_role_name  = local.iam_policy.cloudwatch_role_name
}

module "ec2-setup" {
  source = "../module/ec2"
  depends_on = [module.cloud-infra,
    module.security-group-web-access,
    module.security-group-ssh-access,
    module.security-group-outbound-access,
    module.instance_profile]

  ec2 = [
    for idx, item in var.ec2 :
    {
      ami           = item.ami
      instance_type = item.instance_type
      key_name      = local.key_pair.key_name

      subnet_id = item.subnet_type == "public" ? module.cloud-infra.public_subnet_ids[idx % length(module.cloud-infra.public_subnet_ids)] : module.cloud-infra.private_subnet_ids[idx % length(module.cloud-infra.private_subnet_ids)]

      vpc_security_group_ids = [
        module.security-group-web-access.security_group_details.id,
        module.security-group-ssh-access.security_group_details.id,
        module.security-group-outbound-access.security_group_details.id
      ]

      iam_instance_profile_name = local.instance_profile_name

      user_data = file(item.user_data)

      user_data = templatefile(item.user_data, {
        environment = terraform.workspace,
        log_group_name = local.log_group_name
      })

      tags = merge(local.default_tags, {
        Name = "${idx}-${local.prefix["ec2"]}-${var.general_info.project}-${terraform.workspace}"
      })
  }]
}

module "load_balancer" {
  source     = "../module/load-balancer"
  depends_on = [module.cloud-infra, module.ec2-setup]
  target_group = {
    name        = local.target_group_tags.Name
    target_type = "instance"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = module.cloud-infra.vpc_id

    healthy_threshold   = var.target_group.healthy_threshold
    interval            = var.target_group.interval
    unhealthy_threshold = var.target_group.unhealthy_threshold
    timeout             = var.target_group.timeout
    path                = var.target_group.path
    health_port         = 80

    tags = local.target_group_tags
  }

  target_group_attachment = [
    for instance in local.instance_ids :
    {
      target_group_arn = module.load_balancer.target_group_arn
      instance_id      = instance
      port             = 80
  }]

  load_balancer = {
    name        = local.load_balancer_tags.Name
    is_internal = false
    security_groups = [
      module.security-group-web-access.security_group_details.id,
      module.security-group-ssh-access.security_group_details.id,
      module.security-group-outbound-access.security_group_details.id
    ]

    security_groups = [
      module.security-group-web-access.security_group_details.id,
      module.security-group-ssh-access.security_group_details.id,
      module.security-group-outbound-access.security_group_details.id
    ]

    subnets                          = local.unique_subnets_per_az #concat(module.cloud-infra.public_subnet_ids, module.cloud-infra.private_subnet_ids)
    enable_cross_zone_load_balancing = true
    tags = local.load_balancer_tags
  }

  listener = [{
    load_balancer_arn = module.load_balancer.load_balancer_arn
    port              = 80
    protocol          = "HTTP"
    target_group_arn  = module.load_balancer.target_group_arn
    type              = "forward"
    },
    {
      load_balancer_arn = module.load_balancer.load_balancer_arn
      port              = 443
      protocol          = "HTTPS"
      ssl_policy        = "ELBSecurityPolicy-2016-08"
      certificate_arn   = local.listener_certificate_arn
      target_group_arn  = module.load_balancer.target_group_arn
      type              = "forward"
  }]
}

module "route53" {
  source = "../module/route53"
  depends_on = [module.load_balancer]
  a_records  = var.a_records
  load_balancer_dns     = module.load_balancer.load_balancer_dns_name
  load_balancer_zone_id = module.load_balancer.load_balancer_zone_id
  hosted_zone_id        = local.hosted_zone_id
}
