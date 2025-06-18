output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_details" {
  value = aws_subnet.this
}

output "public_subnet_ids" {
  value = [
    for subnet in aws_subnet.this : subnet.id if subnet.map_public_ip_on_launch
  ]
}

output "private_subnet_ids" {
  value = [
    for subnet in aws_subnet.this : subnet.id if ! subnet.map_public_ip_on_launch
  ]
}

output "internet_gateway_id" {
  value = aws_internet_gateway.this.id
}

output "elastic_ip_ids" {
  value = aws_eip.this.id
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.this.id
}

output "public_route_table_ids" {
  value = aws_route_table.public.id
}

output "private_route_table_ids" {
  value = aws_route_table.private.id
}