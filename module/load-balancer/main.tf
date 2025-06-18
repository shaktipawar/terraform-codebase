resource "aws_lb_target_group" this {
  name        = var.target_group.name
  target_type = var.target_group.target_type
  port        = var.target_group.port
  protocol    = var.target_group.protocol
  vpc_id      = var.target_group.vpc_id
  health_check {
    healthy_threshold   = var.target_group.healthy_threshold
    interval            = var.target_group.interval
    unhealthy_threshold = var.target_group.unhealthy_threshold
    timeout             = var.target_group.timeout
    path                = var.target_group.path
    port                = var.target_group.port
  }
  tags = var.target_group.tags
}

resource "aws_lb_target_group_attachment" this {

  for_each = {
    for idx, attachment in var.target_group_attachment : idx => attachment
  }
  target_group_arn = each.value.target_group_arn
  target_id        = each.value.instance_id
  port             = each.value.port
}

resource "aws_lb" this {
  name                             = var.load_balancer.name
  internal                         = var.load_balancer.is_internal
  load_balancer_type               = "application"
  security_groups                  = var.load_balancer.security_groups
  subnets                          = var.load_balancer.subnets
  enable_cross_zone_load_balancing = var.load_balancer.enable_cross_zone_load_balancing
  tags                             = var.load_balancer.tags
}

resource "aws_lb_listener" this {
  for_each = {
    for idx, item in var.listener : idx => item
  }

  load_balancer_arn = each.value.load_balancer_arn
  port              = each.value.port
  protocol          = each.value.protocol
  default_action {
    target_group_arn = each.value.target_group_arn
    type             = "forward"
  }

  # Conditionally assign ssl_policy and certificate_arn if protocol is HTTPS
  ssl_policy      = each.value.protocol == "HTTPS" ? each.value.ssl_policy : null
  certificate_arn = each.value.protocol == "HTTPS" ? each.value.certificate_arn : null

}


