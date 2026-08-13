resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.project_name}-ingress-vpc"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidr_a
  availability_zone = var.availability_zone_a

  tags = {
    Name = "${var.project_name}-ingress-public-subnet-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidr_b
  availability_zone = var.availability_zone_b

  tags = {
    Name = "${var.project_name}-ingress-public-subnet-b"
  }
}

resource "aws_subnet" "tgw_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.tgw_subnet_cidr_a
  availability_zone = var.availability_zone_a

  tags = {
    Name = "${var.project_name}-ingress-tgw-subnet-a"
  }
}

resource "aws_subnet" "tgw_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.tgw_subnet_cidr_b
  availability_zone = var.availability_zone_b

  tags = {
    Name = "${var.project_name}-ingress-tgw-subnet-b"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project_name}-ingress-igw"
  }
}
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-ingress-alb-"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ingress-alb-sg"
  }
}
resource "aws_lb" "this" {
  name               = "${var.project_name}-ingress-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name = "${var.project_name}-ingress-alb"
  }
}

resource "aws_lb_target_group" "this" {
  name        = "${var.project_name}-ingress-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-ingress-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id = var.tgw_id
  vpc_id             = aws_vpc.this.id
  subnet_ids         = [aws_subnet.tgw_a.id, aws_subnet.tgw_b.id]

  tags = {
    Name = "${var.project_name}-ingress-attachment"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.tgw_route_table_id
}
resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project_name}-ingress-public-a-rt"
  }
}

resource "aws_route_table" "public_b" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project_name}-ingress-public-b-rt"
  }
}

resource "aws_route_table" "tgw_subnet_a" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project_name}-ingress-tgw-subnet-a-rt"
  }
}

resource "aws_route_table" "tgw_subnet_b" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project_name}-ingress-tgw-subnet-b-rt"
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

resource "aws_route" "tgw_a_default" {
  route_table_id         = aws_route_table.tgw_subnet_a.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.tgw_id
}

resource "aws_route" "tgw_b_default" {
  route_table_id         = aws_route_table.tgw_subnet_b.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.tgw_id
}
