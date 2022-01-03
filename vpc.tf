resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    "Name" = "ansible-ec2-instance-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    "Name" = "public-subnet"
  }
}


resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  route_table_id = aws_route_table.main.id
  subnet_id      = aws_subnet.public.id
}


resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "VPC-IGW"
  }
}

resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.main.id
  gateway_id             = aws_internet_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}
