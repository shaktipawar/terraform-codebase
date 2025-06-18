resource "aws_route53_record" "a_record" {
  for_each = {
        for idx, item in var.a_records : idx => item
    }  
  zone_id = var.hosted_zone_id
  name    = each.value
  type    = "A"
  alias {
    name                   = var.load_balancer_dns
    zone_id                = var.load_balancer_zone_id
    evaluate_target_health = true
  }
}