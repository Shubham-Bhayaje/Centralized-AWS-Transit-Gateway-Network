module "transit_gateway" {
  source       = "./modules/transit-gateway"
  project_name = var.project_name
  environment  = var.environment
  tgw_asn      = var.tgw_asn

}


module "spoke_a" {
  source             = "./modules/spoke-vpc"
  project_name       = var.project_name
  name               = "spoke-a"
  vpc_cidr           = "10.0.0.0/16"
  subnet_cidr        = "10.0.1.0/24"
  availability_zone  = "us-east-1a"
  tgw_id             = module.transit_gateway.tgw_id
  tgw_route_table_id = module.transit_gateway.spoke_inspection_rt_id

}

module "spoke_b" {
  source             = "./modules/spoke-vpc"
  project_name       = var.project_name
  name               = "spoke-b"
  vpc_cidr           = "10.1.0.0/16"
  subnet_cidr        = "10.1.1.0/24"
  availability_zone  = "us-east-1a"
  tgw_id             = module.transit_gateway.tgw_id
  tgw_route_table_id = module.transit_gateway.spoke_inspection_rt_id

}
