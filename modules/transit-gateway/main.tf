resource "aws_ec2_transit_gateway" "this" {
  description                     = "${var.project_name} hub TGW"
  amazon_side_asn                 = var.tgw_asn
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  tags = {
    Name        = "${var.project_name}-tgw"
    Environment = var.environment

  }

}

resource "aws_ec2_transit_gateway_route_table" "spoke_inspection" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags = {
    Name = "${var.project_name}-spoke-inspection-rt"
  }

}

resource "aws_ec2_transit_gateway_route_table" "firewall" {
    transit_gateway_id = aws_ec2_transit_gateway.this.id
    tags = {
      Name = "${var.project_name}-firewall-rt"
    }
  
}
