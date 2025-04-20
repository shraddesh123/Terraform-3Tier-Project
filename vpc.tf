# VPC Creation 
resource "aws_vpc" "Main_VPC" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "name" = "WEB_VPC"
  }
}

# Creating 6 Subnets (2 Public and 4 Private )
#public
resource "aws_subnet" "PUBLIC_SUBNET_1" {
  vpc_id                  = aws_vpc.Main_VPC.id
  cidr_block              = var.public_subnet_1_cidrblock
  availability_zone       = var.public_subnet_1_az
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}
resource "aws_subnet" "PUBLIC_SUBNET_2" {
  vpc_id                  = aws_vpc.Main_VPC.id
  cidr_block              = var.public_subnet_2_cidrblock
  availability_zone       = var.public_subnet_1_az
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}
#private
resource "aws_subnet" "name" {
  vpc_id = aws_vpc.Main_VPC.id
}
resource "aws_subnet" "name" {
  vpc_id = aws_vpc.Main_VPC.id
}
resource "aws_subnet" "name" {
  vpc_id = aws_vpc.Main_VPC.id
}
resource "aws_subnet" "name" {
  vpc_id = aws_vpc.Main_VPC.id
}
