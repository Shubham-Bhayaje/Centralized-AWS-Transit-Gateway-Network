output "tgw_id" {
  value = aws_ec2_transit_gateway.this.id
}

output "spoke_inspection_rt_id" {
  value = aws_ec2_transit_gateway_route_table.spoke_inspection.id
}

output "firewall_rt_id" {
  value = aws_ec2_transit_gateway_route_table.firewall.id
}