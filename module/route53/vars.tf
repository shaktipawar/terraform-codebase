variable "load_balancer_dns" {
  description = "DNS name of the load balancer"
  type        = string
}

variable "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  type        = string
}

variable "hosted_zone_id" {
  description = "ID of the Route 53 hosted zone"
  type        = string
}

variable "a_records"{
  description = "List of A records to create in Route 53"
  type = list(string)
}


# variable "root_domain_name" {
#   description = "Root domain name for the Route 53 records"
#   type        = string  
# }

# variable "subdomain_name" {
#   description = "Subdomain name for the Route 53 records"
#   type        = string
# }