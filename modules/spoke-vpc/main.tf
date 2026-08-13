resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-${var.name}-vpc"
  }
}

resource "aws_subnet" "a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.subnet_cidr_a
  availability_zone = var.availability_zone_a

  tags = {
    Name = "${var.project_name}-${var.name}-private-a"
  }

}

resource "aws_subnet" "b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.subnet_cidr_b
  availability_zone = var.availability_zone_b

  tags = {
    Name = "${var.project_name}-${var.name}-private-b"
  }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-${var.name}-rt"
  }

}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.a.id
  route_table_id = aws_route_table.this.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.b.id
  route_table_id = aws_route_table.this.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id = var.tgw_id
  vpc_id             = aws_vpc.this.id
  subnet_ids         = [aws_subnet.a.id, aws_subnet.b.id]
  tags = {
    Name = "${var.project_name}-${var.name}-attachment"
  }

}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.tgw_route_table_id

}

resource "aws_route" "default" {
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.tgw_id
}

# --- EC2 Instance with SSM Access ---

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "instance" {
  name_prefix = "${var.project_name}-${var.name}-sg-"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH from within VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.name}-instance-sg"
  }
}

# --- EC2 Instance Connect Endpoint ---

resource "aws_security_group" "eic_endpoint" {
  name_prefix = "${var.project_name}-${var.name}-eic-sg-"
  vpc_id      = aws_vpc.this.id

  egress {
    description = "SSH to instances"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.project_name}-${var.name}-eic-endpoint-sg"
  }
}

resource "aws_ec2_instance_connect_endpoint" "this" {
  subnet_id          = aws_subnet.a.id
  security_group_ids = [aws_security_group.eic_endpoint.id]
  preserve_client_ip = false

  tags = {
    Name = "${var.project_name}-${var.name}-eic-endpoint"
  }
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.a.id
  vpc_security_group_ids = [aws_security_group.instance.id]

  tags = {
    Name = "${var.project_name}-${var.name}-instance"
  }
}

