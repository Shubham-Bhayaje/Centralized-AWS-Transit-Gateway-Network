module "transit_gateway" {
  source       = "./modules/transit-gateway"
  project_name = var.project_name
  environment  = var.environment
  tgw_asn      = var.tgw_asn
}

module "spoke_a" {
  source              = "./modules/spoke-vpc"
  project_name        = var.project_name
  name                = "spoke-a"
  vpc_cidr            = "10.0.0.0/16"
  subnet_cidr_a       = "10.0.1.0/24"
  subnet_cidr_b       = "10.0.11.0/24"
  availability_zone_a = "us-east-2a"
  availability_zone_b = "us-east-2b"

  tgw_id             = module.transit_gateway.tgw_id
  tgw_route_table_id = module.transit_gateway.spoke_inspection_rt_id
}

module "spoke_b" {
  source              = "./modules/spoke-vpc"
  project_name        = var.project_name
  name                = "spoke-b"
  vpc_cidr            = "10.1.0.0/16"
  subnet_cidr_a       = "10.1.1.0/24"
  subnet_cidr_b       = "10.1.11.0/24"
  availability_zone_a = "us-east-2a"
  availability_zone_b = "us-east-2b"

  tgw_id             = module.transit_gateway.tgw_id
  tgw_route_table_id = module.transit_gateway.spoke_inspection_rt_id
}

module "inspection" {
  source                      = "./modules/inspection-vpc"
  project_name                = var.project_name
  vpc_cidr                    = "10.2.0.0/16"
  tgw_subnet_cidr_a           = "10.2.0.0/28"
  tgw_subnet_cidr_b           = "10.2.1.0/28"
  firewall_subnet_cidr_a      = "10.2.16.0/28"
  firewall_subnet_cidr_b      = "10.2.17.0/28"
  availability_zone_a         = "us-east-2a"
  availability_zone_b         = "us-east-2b"
  tgw_id                      = module.transit_gateway.tgw_id
  tgw_firewall_route_table_id = module.transit_gateway.firewall_rt_id
}

resource "aws_ec2_transit_gateway_route" "spoke_inspection_default" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.inspection.attachment_id
  transit_gateway_route_table_id = module.transit_gateway.spoke_inspection_rt_id
}

resource "aws_ec2_transit_gateway_route" "firewall_to_spoke_a" {
  destination_cidr_block         = "10.0.0.0/16"
  transit_gateway_attachment_id  = module.spoke_a.attachment_id
  transit_gateway_route_table_id = module.transit_gateway.firewall_rt_id
}

resource "aws_ec2_transit_gateway_route" "firewall_to_spoke_b" {
  destination_cidr_block         = "10.1.0.0/16"
  transit_gateway_attachment_id  = module.spoke_b.attachment_id
  transit_gateway_route_table_id = module.transit_gateway.firewall_rt_id
}

module "egress" {
  source                      = "./modules/egress-vpc"
  project_name                = var.project_name
  vpc_cidr                    = "10.3.0.0/16"
  public_subnet_cidr_a        = "10.3.0.0/24"
  public_subnet_cidr_b        = "10.3.1.0/24"
  tgw_subnet_cidr_a           = "10.3.16.0/28"
  tgw_subnet_cidr_b           = "10.3.17.0/28"
  availability_zone_a         = "us-east-2a"
  availability_zone_b         = "us-east-2b"
  tgw_id                      = module.transit_gateway.tgw_id
  tgw_firewall_route_table_id = module.transit_gateway.firewall_rt_id
}

resource "aws_ec2_transit_gateway_route" "firewall_to_egress" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.egress.attachment_id
  transit_gateway_route_table_id = module.transit_gateway.firewall_rt_id
}

module "ingress" {
  source               = "./modules/ingress-vpc"
  project_name         = var.project_name
  vpc_cidr             = "10.4.0.0/16"
  public_subnet_cidr_a = "10.4.0.0/24"
  public_subnet_cidr_b = "10.4.1.0/24"
  tgw_subnet_cidr_a    = "10.4.16.0/28"
  tgw_subnet_cidr_b    = "10.4.17.0/28"
  availability_zone_a  = "us-east-2a"
  availability_zone_b  = "us-east-2b"
  tgw_id               = module.transit_gateway.tgw_id
  tgw_route_table_id   = module.transit_gateway.spoke_inspection_rt_id
}

resource "aws_ec2_transit_gateway_route" "firewall_to_ingress" {
  destination_cidr_block         = "10.4.0.0/16"
  transit_gateway_attachment_id  = module.ingress.attachment_id
  transit_gateway_route_table_id = module.transit_gateway.firewall_rt_id
}