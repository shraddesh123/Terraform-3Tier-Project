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

#creating 3 route table (1 public 2 private)
#public route-table
resource "aws_route_table" "public_RT" {
  vpc_id = aws_vpc.Main_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Main-IGW.id
  }
  tags = {
    Name = "public_RT"
  }
}
#public-subnet association
resource "aws_route_table_association" "public_subnet_1_association" {
  route_table_id = aws_route_table.public_RT.id
  subnet_id      = aws_subnet.public_subnet_1.id
}
resource "aws_route_table_association" "public_subnet_2_association" {
  route_table_id = aws_route_table.public_RT.id
  subnet_id      = aws_subnet.public_subnet_2.id
}
#private route-table for AZ1
resource "aws_route_table" "private_RT1" {
  vpc_id = aws_vpc.Main_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT1.id
  }
  tags = {
    Name = "private_RT_AZ1"
  }
}
#private-subnet1 association
resource "aws_route_table_association" "private_subnet1_association" {
  route_table_id = aws_route_table.private_RT1.id
  subnet_id      = aws_subnet.private_subnet_1.id
}
#private route-table for AZ2
resource "aws_route_table" "private_RT2" {
  vpc_id = aws_vpc.Main_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT2.id
  }
  tags = {
    Name = "private_RT_AZ2"
  }
}
#private-subnet2 association
resource "aws_route_table_association" "private_subnet2_association" {
  route_table_id = aws_route_table.private_RT2.id
  subnet_id      = aws_subnet.private_subnet_2.id
}

#Creating Security-Groups On Each layer
#Internet-facing LB Security-Group

resource "aws_security_group" "Internet-facing-LB-SG" {
  vpc_id = aws_vpc.Main_VPC.id
  tags = {
    Name = "Internet-facing-LB-SG"
  }
}
#Ingress rule
resource "aws_vpc_security_group_ingress_rule" "HTTP" {
  security_group_id = aws_security_group.Internet-facing-LB-SG.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}
#Egress rule
resource "aws_vpc_security_group_egress_rule" "ALL-TRAFFIC" {
  security_group_id = aws_security_group.Internet-facing-LB-SG.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

#Public Security-Group
resource "aws_security_group" "Public-SG" {
  vpc_id = aws_vpc.Main_VPC.id
  tags = {
    Name = "Public-SG"
  }
}
#Ingress rule 1&2
resource "aws_security_group_rule" "Public-Ingress-Rule-1" {
  security_group_id        = aws_security_group.Public-SG.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = aws_security_group.Internet-facing-LB-SG.id
}
resource "aws_security_group_rule" "Public-Ingress-Rule-2" {
  security_group_id = aws_security_group.Public-SG.id
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = [var.My_IP]
}
#Egress rule
resource "aws_security_group_rule" "Public-Egress_Rule" {
  security_group_id = aws_security_group.Public-SG.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]

}
