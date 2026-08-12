variable "project_name" {
  description = "Project prefix used for naming and tagging resources"
  type        = string

}

variable "vpc_cidr" {
  description = "CIDR block for the Inspection VPC"
  type        = string


}
variable "tgw_subnet_cidr_a" {
  description = "CIDR block for the subnet where the TGW attachment's network interface lives"
  type        = string

}
variable "tgw_subnet_cidr_b" {
  description = "CIDR block for the subnet where the TGW attachment's network interface lives"
  type        = string

}
variable "firewall_subnet_cidr_a" {
  description = "CIDR block for the subnet where the AWS Network Firewall endpoint lives"
  type        = string


}
variable "firewall_subnet_cidr_b" {
  description = "CIDR block for the subnet where the AWS Network Firewall endpoint lives"
  type        = string


}
variable "availability_zone_a" {
  description = "Availability Zone this VPC's subnets will be created in (e.g. us-east-1a)"
  type        = string

}
variable "availability_zone_b" {
  description = "Availability Zone this VPC's subnets will be created in (e.g. us-east-1a)"
  type        = string

}


variable "tgw_id" {
  description = "ID of the Transit Gateway to attach the Inspection VPC to"
  type        = string

}

variable "tgw_firewall_route_table_id" {
  description = "ID of the TGW route table (Firewall RT) to associate the Inspection VPC's attachment with"
  type        = string

}


