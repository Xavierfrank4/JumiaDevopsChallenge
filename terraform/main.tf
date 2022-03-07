# Create Jumia VPC

resource "aws_vpc" "jumia_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Create Internet Gateway

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.jumia_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Create Two Public Subnets

resource "aws_subnet" "jumia-public-subnet" {
  count                   = var.item_count
  vpc_id                  = aws_vpc.jumia_vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = var.availability_zone_names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public_${count.index + 1}"
  }
}

# Create Application Public Subnet

resource "aws_subnet" "application-public-subnet" {
  count                   = var.item_count
  vpc_id                  = aws_vpc.jumia_vpc.id
  cidr_block              = var.application_subnet_cidr[count.index]
  availability_zone       = var.availability_zone_names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "application_${count.index + 1}"
  }
}

# Create Custom Route Table
resource "aws_route_table" "jumia-route-table" {
  vpc_id = aws_vpc.jumia_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "${var.project_name}-publicRT"
  }
}

# Associate Public Subnet with Route Table
resource "aws_route_table_association" "a" {
  count          = var.item_count
  subnet_id      = aws_subnet.jumia-public-subnet[count.index].id
  route_table_id = aws_route_table.jumia-route-table.id

}
