/*
------------------- Creating VPC --------------------
*/
resource "aws_vpc" "main-vpc" {
  cidr_block = var.vpc-cidr
  tags = {
    name = "${var.project}-vpc"
  }
}


/*
----------------- creating subnets -------------------------------------
*/
resource "aws_subnet" "public-subnet" {
  for_each = toset(var.public-subnet-cidr)
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = each.value
  availability_zone = data.aws_availability_zones.available.names[lookup(keys(var.public-subnet-cidr),0,0)]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-public-${substr(each.value, -3, 3)}"
  }
}

resource "aws_subnet" "private-subnet" {
  for_each = var.private-subnet-cidr
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = each.value
  availability_zone = data.aws_availability_zones.available.names[lookup(keys(var.public-subnet-cidr),0,0)]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project}-private-${substr(each.value, -3, 3)}"
  }
}

/*
------------------------- creating IGW ----------------------------
*/
resource "aws_internet_gateway" "igw" {
vpc_id = aws_vpc.main-vpc.id
tags = { Name = "${var.project}-igw" }
}

# Public route table
resource "aws_route_table" "public" {
vpc_id = aws_vpc.main-vpc.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.igw.id
}
tags = { Name = "${var.project}-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
for_each = aws_subnet.public-subnet
subnet_id = each.value.id
route_table_id = aws_route_table.public.id
}

# NAT Gateway (single NAT for simplicity) - requires an EIP
resource "aws_eip" "nat" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat" {
allocation_id = aws_eip.nat.id
subnet_id = element(values(aws_subnet.public-subnet)[0]).id
depends_on = [aws_internet_gateway.igw]
}

# Private route table to use NAT for internet access
resource "aws_route_table" "private" {
vpc_id = aws_vpc.main-vpc.id
route {
cidr_block = "0.0.0.0/0"
nat_gateway_id = aws_nat_gateway.nat.id
}
tags = { Name = "${var.project}-private-rt" }
}


resource "aws_route_table_association" "private_assoc" {
for_each = aws_subnet.private-subnet
subnet_id = each.value.id
route_table_id = aws_route_table.private.id
}
