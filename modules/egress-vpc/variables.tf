variable "project_name" {
  description = "Project prefix used for naming and tagging resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the Egress VPC"
  type        = string
}

variable "public_subnet_cidr_a" {
  description = "CIDR block for the public subnet in Availability Zone A"
  type        = string
}

variable "public_subnet_cidr_b" {
  description = "CIDR block for the public subnet in Availability Zone B"
  type        = string
}

variable "tgw_subnet_cidr_a" {
  description = "CIDR block for the TGW subnet in Availability Zone A"
  type        = string
}

variable "tgw_subnet_cidr_b" {
  description = "CIDR block for the TGW subnet in Availability Zone B"
  type        = string
}

variable "availability_zone_a" {
  description = "First Availability Zone for this VPC's subnets"
  type        = string
}

variable "availability_zone_b" {
  description = "Second Availability Zone for this VPC's subnets"
  type        = string
}

variable "tgw_id" {
  description = "ID of the Transit Gateway to attach the Egress VPC to"
  type        = string
}

variable "tgw_firewall_route_table_id" {
  description = "ID of the TGW route table (Firewall RT) to associate the Egress VPC's attachment with"
  type        = string
}