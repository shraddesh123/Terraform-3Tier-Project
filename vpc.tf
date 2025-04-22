# VPC Creation 
resource "aws_vpc" "Main_VPC" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "name" = "WEB_VPC"
  }
}

# Creating 6 Subnets (2 Public and 4 Private )
#public
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.Main_VPC.id
  cidr_block              = var.public_subnet_1_cidrblock
  availability_zone       = var.az1
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.Main_VPC.id
  cidr_block              = var.public_subnet_2_cidrblock
  availability_zone       = var.az2
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

#private
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.Main_VPC.id
  cidr_block        = var.app_private_subnet1_cidr
  availability_zone = var.az1
  tags = {
    Name = "private-subnet-1"
  }
}
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.Main_VPC.id
  cidr_block        = var.app_private_subnet2_cidr
  availability_zone = var.az2
  tags = {
    Name = "private-subnet-2"
  }
}
resource "aws_subnet" "db_private_subnet_1" {
  vpc_id            = aws_vpc.Main_VPC.id
  cidr_block        = var.DB_private_subnet1_cidr
  availability_zone = var.az1
  tags = {
    Name = "db-private-subnet-1"
  }
}
resource "aws_subnet" "db_private_subnet_2" {
  vpc_id            = aws_vpc.Main_VPC.id
  cidr_block        = var.DB_private_subnet2_cidr
  availability_zone = var.az2
  tags = {
    Name = "db-private-subnet-2"
  }
}

#Internet-Gateway creation
resource "aws_internet_gateway" "Main-IGW" {
  vpc_id = aws_vpc.Main_VPC.id
  tags = {
    Name = "Main-IGW"
  }
}

#NAT Gateway creation
#creating 2 EIP for NAT Gateway
resource "aws_eip" "eip1" {
  domain = "vpc"
}
resource "aws_eip" "eip2" {
  domain = "vpc"
}

#NAT Gateway
resource "aws_nat_gateway" "NAT1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "Nat-gateway-1"
  }
  depends_on = [aws_internet_gateway.Main-IGW]
}
resource "aws_nat_gateway" "NAT2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.public_subnet_2.id
  tags = {
    Name = "Nat-gateway-2"
  }
  depends_on = [aws_internet_gateway.Main-IGW]
}
