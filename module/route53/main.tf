resource "aws_route53_record" "a_record" {
  
  # count = var.root_domain_name != "" ? 1 : 0
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

# Create A record for "www.domain.com"
# resource "aws_route53_record" "domain_www" {
#   zone_id = var.hosted_zone_id
#   name    = var.subdomain_name
#   type    = "A"
#   alias {
#     name                   = var.load_balancer_dns
#     zone_id                = var.load_balancer_zone_id
#     evaluate_target_health = true
#   }
# }