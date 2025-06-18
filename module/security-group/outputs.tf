output "security_group_details" {
  value = aws_security_group.security_group
}

# output "security_group_ingress_rules_details" {
#   value = aws_vpc_security_group_ingress_rule.security_group_rules
# }

# output "security_group_egress_rules_details" {
#   value = aws_vpc_security_group_egress_rule.security_group_rules
# }

# output "key_pair_details" {
#   value = aws_key_pair.keypair
# }

# output "security_group_ids" {
#   value = { for sg_key, sg in aws_security_group.this : sg_key => sg.id }
# }



