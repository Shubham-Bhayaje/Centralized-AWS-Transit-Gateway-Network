variable "aws_region" {
  description = "AWS region to deploy the hub (Transit Gateway + spokes) into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short name used as a prefix for resource names and tags"
  type        = string
  default     = "tgw-hub-spoke"
}

variable "environment" {
  description = "Environment tag (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tgw_asn" {
  description = "Amazon-side ASN for the Transit Gateway (must be unique if you later peer regions/on-prem via BGP)"
  type        = number
  default     = 64512
}