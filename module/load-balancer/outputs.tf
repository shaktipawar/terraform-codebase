output "target_group_arn" {
  value       = aws_lb_target_group.this.arn
  description = "ARN of the target group created for the load balancer"
}

output "load_balancer_arn" {
  value       = aws_lb.this.arn
  description = "ARN of the load balancer created"
} 

output "load_balancer_dns_name" {
  value       = aws_lb.this.dns_name
  description = "DNS name of the load balancer"
}

output "load_balancer_zone_id" {
  value       = aws_lb.this.zone_id
  description = "Zone ID of the load balancer"
}