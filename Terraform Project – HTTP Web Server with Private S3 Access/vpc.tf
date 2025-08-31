/*
------------------------------- VPC -----------------------------------------------------
*/
resource "aws_vpc" "main-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${local.enviroment_var}- VPC"
  }
}

/*
------------------------------ Creating Subnets -----------------------------------------
*/

# public subnets

resource "aws_subnet" "public-subnet" {
  count = length(var.public_subnet_cidr)
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = element(var.public_subnet_cidr, count.index)
  availability_zone = data.aws_availability_zones.AZ.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.enviroment_var}-public-subnet-${count.index}"
  }
}

# private subnet

resource "aws_subnet" "Private_subnet" {
  vpc_id     = aws_vpc.main-vpc.id
  count = length(var.private_subnet_cidr)
  cidr_block = element(var.private_subnet_cidr, count.index)
  availability_zone = data.aws_availability_zones.AZ.names[count.index]

  tags = {
    Name = "${local.enviroment_var}-private_subnet-${count.index}"
  }
}


/*
----------------------------------Creating IGW ----------------------------------
*/
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "${local.enviroment_var}-IGW"
  }
}


/*
------------------------------------ create Route Table ------------------------------------------------
*/
# public Route Table 
resource "aws_route_table" "public-route_table" {
  vpc_id = aws_vpc.main-vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${local.enviroment_var}-public-Route-Table"
  }
}

resource "aws_route_table_association" "public-route-associ" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.public-route_table.id
}

# Private Route Table
resource "aws_route_table" "private-route_table" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "${local.enviroment_var}-Private_Route_table"
  }
}
resource "aws_route_table_association" "private-route-associ" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = aws_subnet.Private_subnet[count.index].id
  route_table_id = aws_route_table.private-route_table.id
}

/*
------------------------------- Creating VPC Endpoint -----------------------------------------------------------------
*/

# using this end point to access S3 bucket in private instance 
resource "aws_vpc_endpoint" "accessing-s3-privateEC2" {
  vpc_id       = aws_vpc.main-vpc.id
  service_name = "com.amazonaws.ap-south-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.private-route_table.id]
}
# Attach S3 VPC Endpoint to Private Route Table
  resource "aws_vpc_endpoint_route_table_association" "s3_private_assoc" {
  vpc_endpoint_id = aws_vpc_endpoint.accessing-s3-privateEC2.id
  route_table_id  = aws_route_table.private-route_table.id
}
