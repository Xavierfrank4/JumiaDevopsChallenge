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

# Create A Public Subnets

resource "aws_subnet" "jumia-public-subnet" {
  vpc_id                  = aws_vpc.jumia_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone_names
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

# Create Application Public Subnet

resource "aws_subnet" "application-subnet" {
  vpc_id                  = aws_vpc.jumia_vpc.id
  cidr_block              = var.application_subnet_cidr
  availability_zone       = var.availability_zone_names
  map_public_ip_on_launch = false

  tags = {
    Name = "application_subnet"
  }
}

# Create Database Public Subnet
resource "aws_subnet" "database-subnet" {
  vpc_id                  = aws_vpc.jumia_vpc.id
  cidr_block              = var.database_subnet_cidr
  availability_zone       = var.availability_zone_names
  map_public_ip_on_launch = true

  tags = {
    Name = "Database-Subnet"
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
  subnet_id      = aws_subnet.jumia-public-subnet.id
  route_table_id = aws_route_table.jumia-route-table.id

}

# Associate Database Subnet with Route Table
resource "aws_route_table_association" "db_rt_association" {
  subnet_id      = aws_subnet.database-subnet.id
  route_table_id = aws_route_table.jumia-route-table.id

}

# Create Web Security Group
resource "aws_security_group" "allow_web_traffic" {
  name        = "allow_web_traffic"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.jumia_vpc.id

  ingress {
    description = "HTTP from Everywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "HTTPS from Everywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH from Everywhere"
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
  ami                    = var.ami_id
  key_name               = "terraform"
  instance_type          = var.instance_type
  availability_zone      = var.availability_zone_names
  vpc_security_group_ids = [aws_security_group.microservice_sg.id]
  subnet_id              = aws_subnet.jumia-public-subnet.id
  user_data              = file("user_data.sh")

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.aws_key_pair)
  }

  tags = {
    Name = "Application_Server"
  }

}


#Create Database Security Group
resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow inbout traffic from microservices"
  vpc_id      = aws_vpc.jumia_vpc.id

  ingress {
    description     = "Allow TCP from Microservices"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.microservice_sg.id]
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
    Name = "RDS_Database_SG"
  }

}


#Create EC2 Database Instance

resource "aws_instance" "database" {
  ami                    = var.ami_id
  key_name               = "terraform"
  instance_type          = var.instance_type
  availability_zone      = var.availability_zone_names
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  subnet_id              = aws_subnet.database-subnet.id
  user_data              = file("user_data.sh")

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.aws_key_pair)
  }

  tags = {
    Name = "Database_Server"
  }

}


# Create Load Balancer Server Instance
resource "aws_instance" "load_balancer" {
  ami                    = var.ami_id
  key_name               = "terraform"
  instance_type          = var.instance_type
  availability_zone      = var.availability_zone_names
  vpc_security_group_ids = [aws_security_group.allow_web_traffic.id]
  subnet_id              = aws_subnet.jumia-public-subnet.id
  user_data              = file("user_data.sh")

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.aws_key_pair)
  }

  tags = {
    Name = "Load_Balancer_Server"
  }

}
