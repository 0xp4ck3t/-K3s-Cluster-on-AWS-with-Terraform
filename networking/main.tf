# --- networking/main.tf ---


data "aws_availability_zones" "available" {}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

resource "aws_vpc" "TF_VPC" {
  cidr_block           = var.aws_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "TF_VPC"
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_subnet" "TF_public_subnet" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.TF_VPC.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "TF_public_${count.index + 1}"
  }
}

resource "aws_subnet" "TF_private_subnet" {
  count             = var.private_sn_count
  vpc_id            = aws_vpc.TF_VPC.id
  cidr_block        = var.private_cidrs[count.index]
  availability_zone = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "TF_private_${count.index + 1}"
  }
}

resource "aws_route_table_association" "TF_public_assoc" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.TF_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.TF_public_RT.id
}


resource "aws_internet_gateway" "TF_internet_GW" {
  vpc_id = aws_vpc.TF_VPC.id
  tags = {
    Name = "TF_IGW"
  }
}

resource "aws_route_table" "TF_public_RT" {
  vpc_id = aws_vpc.TF_VPC.id
  tags = {
    Name = "TF_public_RT"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.TF_public_RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.TF_internet_GW.id
}

resource "aws_default_route_table" "TF_private_RT" {
  default_route_table_id = aws_vpc.TF_VPC.default_route_table_id
  tags = {
    Name = "TF_private_RT"
  }
}

resource "aws_security_group" "TF_SG" {
  for_each    = var.security_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.TF_VPC.id
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "TF_RDS_SG" {
  count      = var.db_subnet_group == true ? 1 : 0
  name       = "tf_rds_sg"
  subnet_ids = aws_subnet.TF_private_subnet.*.id
  tags = {
    Name = "TF_RDS_SNG"
  }
}

























