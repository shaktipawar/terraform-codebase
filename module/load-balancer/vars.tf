variable "target_group" {
  type = object({
    name                = string
    target_type         = string
    port                = number
    protocol            = string
    vpc_id              = string
    healthy_threshold   = string
    interval            = string
    unhealthy_threshold = string
    timeout             = string
    path                = string
    health_port         = string
    tags                = map(string)
  })
  description = "List of target groups with their configurations"
}

variable "target_group_attachment" {
  type = list(object({
    target_group_arn = string
    instance_id      = string
    port             = number
  }))
  description = "Configuration for the target group attachment including target group ARN, target ID, and port."
}

variable "load_balancer" {
  type = object({
    name                             = string
    is_internal                      = bool
    security_groups                  = list(string)
    subnets                          = list(string)
    enable_cross_zone_load_balancing = bool
  tags = map(string) })
  description = "Provide load balancer details"
}

variable "listener" {
  type = list(object({
    load_balancer_arn = string
    port              = number
    protocol          = string
    ssl_policy        = optional(string)
    certificate_arn   = optional(string)
    target_group_arn  = string
    type              = string
  }))
  description = "Configuration for the listener including load balancer ARN, port, protocol, SSL policy, certificate ARN, and default action."
}