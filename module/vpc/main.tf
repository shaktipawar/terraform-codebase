resource "aws_vpc" this {
  cidr_block           = var.vpc.cidr_block
  instance_tenancy     = var.vpc.instance_tenancy
  enable_dns_support   = var.vpc.enable_dns_support
  enable_dns_hostnames = var.vpc.enable_dns_hostnames
  tags                 = var.vpc.tags
}

resource "aws_subnet" this {

  # for_each works with map / tuple
  # Hence, we need this for_each to iterate over the list of subnets defined in the variable
  for_each = {
    for idx, subnet in var.subnets : idx => subnet
  }
    vpc_id                 = each.value.vpc_id
    cidr_block             = each.value.cidr_block
    availability_zone      = each.value.availability_zone
    map_public_ip_on_launch = each.value.map_public_ip_on_launch
    tags = each.value.tags
}

resource "aws_internet_gateway" this {
    vpc_id = var.internet_gateway.vpc_id
    tags = var.internet_gateway.tags
}

resource "aws_key_pair" this {
  #count      = var.need_key_pair ? 1 : 0  # Only create resource if need_key_pair is true
  key_name   = var.key_pair["key_name"]   #"keypair-terraform-codebase"
  public_key = var.key_pair["public_key"] #file(".ssh/ssh-keypair-terraform-codebase.pub")
  tags       = var.key_pair["tags"]
}

resource "aws_eip" this {

    tags = var.elastic_ips.tags
}

resource "aws_nat_gateway" this {
    
    allocation_id = var.nat_gateway.allocation_id
    subnet_id = var.nat_gateway.subnet_id
    tags = var.nat_gateway.tags
}

resource "aws_route_table" "public" {

    vpc_id = var.route_table_public.vpc_id
    route {
        cidr_block = var.route_table_public.cidr_block // Allow IPv4 Traffic
        gateway_id = var.route_table_public.internet_gateway_id
    }
    tags = var.route_table_public.tags
}

resource "aws_route_table" "private" {

    vpc_id = var.route_table_private.vpc_id
    route {
        cidr_block = var.route_table_private.cidr_block // Allow IPv4 Traffic
        nat_gateway_id = var.route_table_private.nat_gateway_id
    }
    tags = var.route_table_private.tags
}

resource "aws_route_table_association" this {

    for_each = {
        for idx, associations in var.route_table_associations : idx => associations
    }
    subnet_id = each.value.subnet_id
    route_table_id = each.value.route_table_id
}





# resource "aws_route_table" "route_table_private" {

#     # for_each = {
#     #     for idx, route in var.route_table_private : idx => route
#     # }

#     # vpc_id = each.value.vpc_id
    
#     # route {
#     #     cidr_block = each.value.cidr_block // Allow IPv4 Traffic
#     #     nat_gateway_id = each.value.nat_gateway_id
#     # }

#     # # route {
#     # #     ipv6_cidr_block = each.value.ipv6_cidr_block // Allow IPv4 Traffic
#     # #     egress_only_gateway_id = each.value.nat_gateway_id
#     # # }

#     # tags = each.value.tags

#     vpc_id = var.route_table_private.vpc_id
    
#     route {
#         cidr_block = var.route_table_private.cidr_block // Allow IPv4 Traffic
#         nat_gateway_id = var.route_table_private.nat_gateway_id
#     }

#     # route {
#     #     ipv6_cidr_block = each.value.ipv6_cidr_block // Allow IPv4 Traffic
#     #     egress_only_gateway_id = each.value.nat_gateway_id
#     # }

#     tags = var.route_table_private.tags
# }

# resource "aws_route_table" "route_table_public" {

#     # for_each = {
#     #     for idx, route in var.route_table : idx => route
#     # }

#     vpc_id = var.route_table_public.vpc_id
    
#     route {
#         cidr_block = var.route_table_public.cidr_block // Allow IPv4 Traffic
#         gateway_id = var.route_table_public.internet_gateway_id
#     }

#     # route{
#     #     ipv6_cidr_block = var.route_table_public.ipv6_cidr_block // Allow IPv6 Traffic
#     #     egress_only_gateway_id = var.route_table_public.internet_gateway_id
#     # }

#     tags = var.route_table_public.tags
# }

# resource "aws_nat_gateway" "nat_gateway" {

#     # for_each = {
#     #     for idx, nat in var.nat_gateway : idx => nat
#     # }

#     # allocation_id = each.value.allocation_id
#     # subnet_id = each.value.subnet_id
#     # tags = each.value.tags

#     allocation_id = var.nat_gateway.allocation_id
#     subnet_id = var.nat_gateway.subnet_id
#     tags = var.nat_gateway.tags
# }

# resource "aws_eip" "elastic_ip" {
#     for_each = {
#         for idx, eip in var.elastic_ips : idx => eip
#     }
#     tags = each.value.tags
# }