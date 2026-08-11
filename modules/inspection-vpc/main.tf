resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.project_name}-inspection-vpc"
  }

}

resource "aws_subnet" "tgw" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.tgw_subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = "${var.project_name}-inspection-tgw-subnet"
  }

}
resource "aws_subnet" "firewall" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.firewall_subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = "${var.project_name}-inspection-firewall-subnet"
  }

}
