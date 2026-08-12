output "vpc_id" {
  value = aws_vpc.this.id


}
output "subnet_id_a" {
  value = aws_subnet.a.id
}

output "subnet_id_b" {
  value = aws_subnet.b.id
}

output "attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.this.id

}
