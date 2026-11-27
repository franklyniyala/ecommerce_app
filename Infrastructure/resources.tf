# VPC
resource "aws_vpc" "ecommerce_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ecommerce_vpc"
  }
}

# Public Subnets
resource "aws_subnet" "ecommerce_public_subnet" {
  vpc_id                  = aws_vpc.ecommerce_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                                          = "ecommerce_public_subnet"
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/ecommerce-eks-cluster" = "shared"

  }
}

resource "aws_subnet" "ecommerce_public_subnet2" {
  vpc_id                  = aws_vpc.ecommerce_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name                                          = "ecommerce_public_subnet2"
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/ecommerce-eks-cluster" = "shared"
  }
}

# Private Subnets
resource "aws_subnet" "ecommerce_private_subnet" {
  vpc_id            = aws_vpc.ecommerce_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name                                          = "ecommerce_private_subnet"
    "kubernetes.io/role/internal-elb"             = "1"
    "kubernetes.io/cluster/ecommerce-eks-cluster" = "shared"
  }
}

resource "aws_subnet" "ecommerce_private_subnet2" {
  vpc_id            = aws_vpc.ecommerce_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name                                          = "ecommerce_private_subnet2"
    "kubernetes.io/role/internal-elb"             = "1"
    "kubernetes.io/cluster/ecommerce-eks-cluster" = "shared"
  }
}

# Elastic IP
resource "aws_eip" "ecommerce_eip" {
  domain = "vpc"
}

# NAT Gateway
resource "aws_nat_gateway" "ecommerce_ngw" {
  subnet_id     = aws_subnet.ecommerce_public_subnet.id
  allocation_id = aws_eip.ecommerce_eip.id

  tags = {
    Name = "ecommerce_ngw"
  }
  depends_on = [
  aws_internet_gateway.ecommerce_igw]
}

# Internet Gateway
resource "aws_internet_gateway" "ecommerce_igw" {
  vpc_id = aws_vpc.ecommerce_vpc.id

  tags = {
    Name = "ecommerce_igw"
  }
}

# Public Route Table
resource "aws_route_table" "ecommerce_rt" {
  vpc_id = aws_vpc.ecommerce_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecommerce_igw.id
  }

  tags = {
    Name = "ecommerce_rt"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "ecommerce_rta" {
  subnet_id      = aws_subnet.ecommerce_public_subnet.id
  route_table_id = aws_route_table.ecommerce_rt.id
}

resource "aws_route_table_association" "ecommerce_rta2" {
  subnet_id      = aws_subnet.ecommerce_public_subnet2.id
  route_table_id = aws_route_table.ecommerce_rt.id
}

# Private Route Table
resource "aws_route_table" "ecommerce_private_rt" {
  vpc_id = aws_vpc.ecommerce_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ecommerce_ngw.id
  }

  tags = {
    Name = "ecommerce_private_rt"
  }
}

# Private Route Table Association
resource "aws_route_table_association" "ecommerce_private_rta" {
  subnet_id      = aws_subnet.ecommerce_private_subnet.id
  route_table_id = aws_route_table.ecommerce_private_rt.id
}

# Second Private Route Table Association
resource "aws_route_table_association" "ecommerce_private_rta2" {
  subnet_id      = aws_subnet.ecommerce_private_subnet2.id
  route_table_id = aws_route_table.ecommerce_private_rt.id
}


