# SINGLE RESOURCE
variable "vpc" {
  type = object({
    cidr_block           = string
    instance_tenancy     = string
    enable_dns_support   = bool
    enable_dns_hostnames = bool
    tags                 = map(string)
  })
}

# ARRAY OF RESOURCE
variable "subnets" {
  type = list(object({
    vpc_id           = string
    cidr_block       = string
    availability_zone     = string
    map_public_ip_on_launch = bool
    tags             = map(string)
  }))
}

# SINGLE RESOURCE
variable "internet_gateway" {
  type = object({
    vpc_id = string
    tags   = map(string)
  })
}

# SINGLE RESOURCE
variable "key_pair" {
  description = "Groups attributes of aws key_pair resource"
  type = object({
    key_name   = string
    public_key = string
    tags       = map(string)
  })
}

# SINGLE RESOURCE
variable "elastic_ips" {
  type = object({
    tags   = map(string)
  })
}

# SINGLE RESOURCE
variable "nat_gateway" {
  type = object({
    allocation_id = string
    subnet_id     = string
    tags          = map(string)
  })
}

# SINGLE RESOURCE
variable "route_table_public" {
  type = object({
    vpc_id = string
    cidr_block              = string
    ipv6_cidr_block         = string
    internet_gateway_id     = string
    tags  = map(string)
  })
}

# SINGLE RESOURCE
variable "route_table_private" {
  type = object({
    vpc_id = string
    cidr_block              = string
    ipv6_cidr_block         = string
    nat_gateway_id     = string
    tags  = map(string)
  })
}

variable "route_table_associations" {
  type = list(object({
    subnet_id      = string
    route_table_id = string
  }))
}