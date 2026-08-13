resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.project_name}-inspection-vpc"
  }

}

resource "aws_subnet" "tgw_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.tgw_subnet_cidr_a
  availability_zone = var.availability_zone_a

  tags = {
    Name = "${var.project_name}-inspection-tgw-subnet-a"
  }
}

resource "aws_subnet" "tgw_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.tgw_subnet_cidr_b
  availability_zone = var.availability_zone_b

  tags = {
    Name = "${var.project_name}-inspection-tgw-subnet-b"
  }
}

resource "aws_subnet" "firewall_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.firewall_subnet_cidr_a
  availability_zone = var.availability_zone_a

  tags = {
    Name = "${var.project_name}-inspection-firewall-subnet-a"
  }
}

resource "aws_subnet" "firewall_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.firewall_subnet_cidr_b
  availability_zone = var.availability_zone_b

  tags = {
    Name = "${var.project_name}-inspection-firewall-subnet-b"
  }
}

resource "aws_networkfirewall_rule_group" "allow_all" {
  capacity = 100
  name     = "${var.project_name}-allow-all"
  type     = "STATEFUL"

  rule_group {
    rules_source {
      stateful_rule {
        action = "PASS"
        header {
          protocol         = "TCP"
          source           = "ANY"
          source_port      = "ANY"
          destination      = "ANY"
          destination_port = "ANY"
          direction        = "ANY"
        }
        rule_option {
          keyword = "sid:1"
        }
      }
      stateful_rule {
        action = "PASS"
        header {
          protocol         = "UDP"
          source           = "ANY"
          source_port      = "ANY"
          destination      = "ANY"
          destination_port = "ANY"
          direction        = "ANY"
        }
        rule_option {
          keyword = "sid:2"
        }
      }
      stateful_rule {
        action = "DROP"
        header {
          protocol         = "ICMP"
          source           = "ANY"
          source_port      = "ANY"
          destination      = "ANY"
          destination_port = "ANY"
          direction        = "ANY"
        }
        rule_option {
          keyword = "sid:3"
        }
      }
    }
  }
}

resource "aws_networkfirewall_firewall_policy" "this" {
  name = "${var.project_name}-firewall-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.allow_all.arn
    }
  }
}
resource "aws_networkfirewall_firewall" "this" {
  name                = "${var.project_name}-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.this.arn
  vpc_id              = aws_vpc.this.id

  subnet_mapping {
    subnet_id = aws_subnet.firewall_a.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.firewall_b.id
  }

  tags = {
    Name = "${var.project_name}-firewall"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id     = var.tgw_id
  vpc_id                 = aws_vpc.this.id
  subnet_ids             = [aws_subnet.tgw_a.id, aws_subnet.tgw_b.id]
  appliance_mode_support = "enable"
  tags = {
    Name = "${var.project_name}-inspection-attachment"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.tgw_firewall_route_table_id

}

resource "aws_route_table" "tgw_subnet_a" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project_name}-inspection-tgw-subnet-a-rt"
  }
}

resource "aws_route_table" "tgw_subnet_b" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project_name}-inspection-tgw-subnet-b-rt"
  }
}

resource "aws_route_table" "firewall_subnet_a" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project_name}-inspection-firewall-subnet-a-rt"
  }
}

resource "aws_route_table" "firewall_subnet_b" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project_name}-inspection-firewall-subnet-b-rt"
  }
}

resource "aws_route_table_association" "tgw_a" {
  subnet_id      = aws_subnet.tgw_a.id
  route_table_id = aws_route_table.tgw_subnet_a.id
}

resource "aws_route_table_association" "tgw_b" {
  subnet_id      = aws_subnet.tgw_b.id
  route_table_id = aws_route_table.tgw_subnet_b.id
}

resource "aws_route_table_association" "firewall_a" {
  subnet_id      = aws_subnet.firewall_a.id
  route_table_id = aws_route_table.firewall_subnet_a.id
}

resource "aws_route_table_association" "firewall_b" {
  subnet_id      = aws_subnet.firewall_b.id
  route_table_id = aws_route_table.firewall_subnet_b.id
}

resource "aws_route" "tgw_to_firewall_a" {
  route_table_id         = aws_route_table.tgw_subnet_a.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.firewall_endpoint_id_a
}

resource "aws_route" "tgw_to_firewall_b" {
  route_table_id         = aws_route_table.tgw_subnet_b.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.firewall_endpoint_id_b
}
resource "aws_route" "firewall_to_tgw_a" {
  route_table_id         = aws_route_table.firewall_subnet_a.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.tgw_id
}

resource "aws_route" "firewall_to_tgw_b" {
  route_table_id         = aws_route_table.firewall_subnet_b.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.tgw_id
}

