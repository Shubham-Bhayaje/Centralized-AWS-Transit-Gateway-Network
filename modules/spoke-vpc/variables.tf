
variable "project_name" {
  description = "Prefix used for naming resources"
  type        = string

}


variable "vpc_cidr" {
  description = "CIDR block for this spoke's VPC"
  type        = string

}
variable "name" {
  description = "Name identifier for this spoke, used for naming and tagging resources (e.g. spoke-a, spoke-b)"
  type        = string

}

variable "availability_zone_a" {
  description = "Availability Zone this spoke's subnet will be created in (e.g. us-east-1a)"
  type        = string

}

variable "availability_zone_b" {
  description = "Availability Zone this spoke's subnet will be created in (e.g. us-east-1a)"
  type        = string

}

variable "subnet_cidr_a" {
  description = "a smaller slice within vpc_cidr"
  type        = string

}

variable "subnet_cidr_b" {
  description = "a smaller slice within vpc_cidr"
  type        = string

}

variable "tgw_id" {
  description = "tgw_id — which Transit Gateway to attach this spoke's VPC to. This will come from module.transit_gateway.tgw_id"
  type        = string

}

variable "tgw_route_table_id" {
  description = "tgw_route_table_id — which TGW route table to associate the attachment with (the Spoke Inspection RT). This comes from module.transit_gateway.spoke_inspection_rt_id"
  type        = string

}
