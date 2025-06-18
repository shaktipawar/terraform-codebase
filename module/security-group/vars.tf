variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to which the security group will be attached."
}

variable "security_group_name" {
  type        = string
  description = "The name of the security group."
  default     = "security-group-ping-terraform-codebase"
}

variable "security_group_description" {
  type        = string
  description = "A description for the security group."
  default     = "Security group for Ping"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the security group."
  default     = {}
}

variable "security_group_rules_ingress" {
  description = "List of Security Groups Rules"
  type = map(object({
    is_ipv4           = optional(bool, true) # Optional field to indicate if the rule is for IPv4
    security_group_id = string
    cidr_ipv4         = optional(string, "0.0.0.0/0")
    cidr_ipv6         = optional(string, null) # Optional field for IPv6 CIDR blocks
    from_port         = number
    to_port           = number
    ip_protocol       = string
    tags              = map(string)
  }))
}

variable "security_group_rules_egress" {
  description = "List of Security Groups Rules"
  type = map(object({
    is_ipv4           = optional(bool, true) # Optional field to indicate if the rule is for IPv4
    security_group_id = string
    cidr_ipv4         = optional(string, "0.0.0.0/0") # Optional field for IPv4 CIDR blocks
    cidr_ipv6         = optional(string, null)        # Optional field for IPv6 CIDR blocks
    from_port         = number
    to_port           = number
    ip_protocol       = string
    tags              = map(string)
  }))
}