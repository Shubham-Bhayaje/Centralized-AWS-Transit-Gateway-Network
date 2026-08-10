variable "project_name" {
  description = "Prefix used for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment tag"
  type        = string
}

variable "tgw_asn" {
  description = "Amazon-side ASN for the Transit Gateway"
  type        = number
}