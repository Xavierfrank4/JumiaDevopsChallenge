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
resource "aws_route_table_association" "rt_association" {
  count          = var.item_count
  subnet_id      = aws_subnet.jumia-public-subnet[count.index].id
  route_table_id = aws_route_table.jumia-route-table.id

}

# Create Web Security Group
resource "aws_security_group" "allow_web_traffic" {
  name        = "allow_web_traffic"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.jumia_vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }

}

# Create Microservice Security Group
resource "aws_security_group" "microservice_sg" {
  name        = "microservice_sg"
  description = "Allow TCP inbound traffic from ALB"
  vpc_id      = aws_vpc.jumia_vpc.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.allow_web_traffic.id]

  }

  ingress {
    description = "Allow SSH"
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "microservice"
  }

}

# Create EC2 Instances

resource "aws_instance" "microservice_app" {
  count                  = var.item_count
  ami                    = var.ami_id
  key_name               = "terraform"
  instance_type          = var.instance_type
  availability_zone      = var.availability_zone_names[count.index]
  vpc_security_group_ids = [aws_security_group.microservice_sg.id]
  subnet_id              = aws_subnet.jumia-public-subnet[count.index].id
  user_data              = file("user_data.sh")

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.aws_key_pair)
  }

  tags = {
    Name = "Application_Server_${count.index + 1}"
  }

}
