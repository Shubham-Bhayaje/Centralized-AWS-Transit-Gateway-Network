resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.project_name}-egress-vpc"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidr_a
  availability_zone = var.availability_zone_a

  tags = {
    Name = "${var.project_name}-egress-public-subnet-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidr_b
  availability_zone = var.availability_zone_b

  tags = {
    Name = "${var.project_name}-egress-public-subnet-b"
  }
}

resource "aws_subnet" "tgw_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.tgw_subnet_cidr_a
  availability_zone = var.availability_zone_a

  tags = {
    Name = "${var.project_name}-egress-tgw-subnet-a"
  }
}

resource "aws_subnet" "tgw_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.tgw_subnet_cidr_b
  availability_zone = var.availability_zone_b

  tags = {
    Name = "${var.project_name}-egress-tgw-subnet-b"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project_name}-egress-igw"
  }

}

resource "aws_eip" "nat_a" {
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-egress-nat-eip-a"
  }
}

resource "aws_eip" "nat_b" {
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-egress-nat-eip-b"
  }
}

resource "aws_nat_gateway" "a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name = "${var.project_name}-egress-nat-a"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_b.id

  tags = {
    Name = "${var.project_name}-egress-nat-b"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id = var.tgw_id
  vpc_id             = aws_vpc.this.id
  subnet_ids         = [aws_subnet.tgw_a.id, aws_subnet.tgw_b.id]

  tags = {
    Name = "${var.project_name}-egress-attachment"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.tgw_firewall_route_table_id
}

resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project_name}-egress-public-a-rt"
  }
}

resource "aws_route_table" "public_b" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project_name}-egress-public-b-rt"
  }
}

resource "aws_route_table" "tgw_subnet_a" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project_name}-egress-tgw-subnet-a-rt"
  }
}

resource "aws_route_table" "tgw_subnet_b" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project_name}-egress-tgw-subnet-b-rt"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_a.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_b.id
}

resource "aws_route_table_association" "tgw_a" {
  subnet_id      = aws_subnet.tgw_a.id
  route_table_id = aws_route_table.tgw_subnet_a.id
}

resource "aws_route_table_association" "tgw_b" {
  subnet_id      = aws_subnet.tgw_b.id
  route_table_id = aws_route_table.tgw_subnet_b.id
}

resource "aws_route" "public_a_default" {
  route_table_id         = aws_route_table.public_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route" "public_b_default" {
  route_table_id         = aws_route_table.public_b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route" "tgw_a_to_nat" {
  route_table_id         = aws_route_table.tgw_subnet_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.a.id
}

resource "aws_route" "tgw_b_to_nat" {
  route_table_id         = aws_route_table.tgw_subnet_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.b.id
}
