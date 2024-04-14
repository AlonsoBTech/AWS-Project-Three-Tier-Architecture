resource "aws_vpc" "three_tier" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Three Tier VPC"
  }
}

resource "aws_subnet" "web_tier_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.three_tier.id
  cidr_block              = local.web_subnet_cidr[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true


  tags = {
    Name = "Web Tier Public Subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "app_tier_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.three_tier.id
  cidr_block              = local.app_subnet_cidr[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false


  tags = {
    Name = "App Tier Private Subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "data_tier_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.three_tier.id
  cidr_block              = local.data_subnet_cidr[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false


  tags = {
    Name = "Data Tier Private Subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "three_tier_igw" {
  vpc_id = aws_vpc.three_tier.id

  tags = {
    Name = "Three Tier IGW"
  }
}

resource "aws_eip" "nat_eip" {
  count  = 2
  domain = "vpc"

  tags = {
    Name = "NAT EIP-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "three_tier_nat" {
  count         = 2
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.web_tier_subnet.*.id[count.index]

  depends_on = [aws_internet_gateway.three_tier_igw]

  tags = {
    Name = "Three Tier NAT-${count.index + 1}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.three_tier.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.three_tier_igw.id
  }

  tags = {
    Name = "Three Tier Public RT"
  }
}

resource "aws_default_route_table" "default_rt" {
  default_route_table_id = aws_vpc.three_tier.default_route_table_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.three_tier_nat[0].id
  }

  tags = {
    Name = "Three Tier Default RT"
  }
}

resource "aws_route_table_association" "public_rt_asso_1" {
  count          = 2
  subnet_id      = aws_subnet.web_tier_subnet.*.id[count.index]
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_asso_1" {
  count          = 2
  subnet_id      = aws_subnet.app_tier_subnet.*.id[count.index]
  route_table_id = aws_default_route_table.default_rt.id
}

resource "aws_route_table_association" "private_rt_asso_2" {
  count          = 2
  subnet_id      = aws_subnet.data_tier_subnet.*.id[count.index]
  route_table_id = aws_default_route_table.default_rt.id
}