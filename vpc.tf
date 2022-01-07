################################################################
# VPC Resources us-east-1
################################################################
data "aws_availability_zones" "azs" {
  provider = aws.region-main
  state    = "available"
}

data "aws_availability_zones" "worker_azs" {
  provider = aws.region-worker
  state    = "available"
}

resource "aws_vpc" "main" {
  provider             = aws.region-main
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "main-vpc-jenkins"
  }
}

resource "aws_vpc" "worker" {
  provider             = aws.region-worker
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "worker-vpc-jenkins"
  }
}

resource "aws_internet_gateway" "igw" {
  provider = aws.region-main
  vpc_id   = aws_vpc.main.id
}

resource "aws_internet_gateway" "worker" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.worker.id
}

resource "aws_subnet" "public_1" {
  provider                = aws.region-main
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.azs.names, 0)

  tags = {
    "Name" = "public-subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  provider                = aws.region-main
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.azs.names, 1)

  tags = {
    "Name" = "public-subnet-2"
  }
}

resource "aws_subnet" "public_worker_1" {
  provider                = aws.region-worker
  vpc_id                  = aws_vpc.worker.id
  cidr_block              = "192.168.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.worker_azs.names, 0)

  tags = {
    "Name" = "public-subnet-worker-1"
  }
}

resource "aws_route_table" "main_internet_route" {
  provider = aws.region-main
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block                = "192.168.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1_useast2.id
  }

  lifecycle {
    ignore_changes = all
  }

  tags = {
    "Name" = "Main-Region-RT"
  }
}

resource "aws_route_table" "worker_internet_route" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.worker.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.worker.id
  }

  route {
    cidr_block                = "10.0.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1_useast2.id
  }

  lifecycle {
    ignore_changes = all
  }

  tags = {
    "Name" = "Worker-Region-RT"
  }
}

# Overwrite the default route table VPC(main) with new route table entries
resource "aws_main_route_table_association" "main_default_rt_assoc" {
  provider       = aws.region-main
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.main_internet_route.id
}

# Overwrite the default route table VPC(worker) with new route table entries
resource "aws_main_route_table_association" "worker_default_rt_assoc" {
  provider       = aws.region-worker
  vpc_id         = aws_vpc.worker.id
  route_table_id = aws_route_table.worker_internet_route.id
}

# Association between main route table and public_1 in us-east-1
resource "aws_route_table_association" "internet_association" {
  provider       = aws.region-main
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.main_internet_route.id
}

# Association between main route table and public_worker_1 in us-east-2
resource "aws_route_table_association" "internet_association_worker" {
  provider       = aws.region-worker
  subnet_id      = aws_subnet.public_worker_1.id
  route_table_id = aws_route_table.worker_internet_route.id
}

################################################################
# VPC Peering
################################################################

# Initiate Peering connection requests from us-east-1
resource "aws_vpc_peering_connection" "useast1_useast2" {
  provider    = aws.region-main
  peer_vpc_id = aws_vpc.worker.id
  vpc_id      = aws_vpc.main.id
  peer_region = var.region-worker
}

# Accept VPC peering requests in us-east-2 from us-east-1
resource "aws_vpc_peering_connection_accepter" "accept_peering" {
  provider                  = aws.region-worker
  vpc_peering_connection_id = aws_vpc_peering_connection.useast1_useast2.id
  auto_accept               = true
}
