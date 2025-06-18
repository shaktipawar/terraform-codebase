resource "aws_security_group" "security_group" {
  vpc_id      = var.vpc_id
  name        = var.security_group_name        
  description = var.security_group_description
  tags        = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "security_group_rules" {
  for_each          = var.security_group_rules_ingress
  security_group_id = each.value["security_group_id"]
  ip_protocol       = each.value["ip_protocol"]
  tags              = each.value["tags"]

  # from_port         = each.value["from_port"]
  # to_port           = each.value["to_port"]
  # Conditionally set from_port and to_port only if ip_protocol is not "-1"
  from_port         = each.value["ip_protocol"] != "-1" ? each.value["from_port"] : null
  to_port           = each.value["ip_protocol"] != "-1" ? each.value["to_port"] : null

  # Conditionally set cidr_ipv4 or cidr_ipv6 based on is_ipv4
  cidr_ipv4 = each.value["is_ipv4"] ? each.value["cidr_ipv4"] : null
  cidr_ipv6 = each.value["is_ipv4"] ? null : each.value["cidr_ipv6"]
}

resource "aws_vpc_security_group_egress_rule" "security_group_rules" {
  for_each          = var.security_group_rules_egress
  security_group_id = each.value["security_group_id"]
  ip_protocol       = each.value["ip_protocol"]
  tags              = each.value["tags"]

  # Conditionally set from_port and to_port only if ip_protocol is not "-1"
  from_port         = each.value["ip_protocol"] != "-1" ? each.value["from_port"] : null
  to_port           = each.value["ip_protocol"] != "-1" ? each.value["to_port"] : null

  # Conditionally set cidr_ipv4 or cidr_ipv6 based on is_ipv4
  cidr_ipv4 = each.value["is_ipv4"] ? each.value["cidr_ipv4"] : null
  cidr_ipv6 = each.value["is_ipv4"] ? null : each.value["cidr_ipv6"]
}