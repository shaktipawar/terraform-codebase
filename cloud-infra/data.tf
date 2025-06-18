data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_route53_zone" "hosted_zone" {
  name         = var.domain_name #"example.com"
  private_zone = false
}

data "aws_acm_certificate" "issued" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}