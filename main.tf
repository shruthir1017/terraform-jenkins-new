provider "aws" {
  region = "us-east-1"  
}

# VPC creation
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "my_vpc"
  }
}

# Create Internet Gateway for public internet access
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_internet_gateway"
  }
}

# Create public subnet
resource "aws_subnet" "my_public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"  # Specify a subnet CIDR block
  availability_zone       = "us-east-1a"  
  map_public_ip_on_launch = true            # Auto-assign public IPs

  tags = {
    Name = "my_public_subnet"
  }
}

# Create route table for the public subnet
resource "aws_route_table" "my_public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "my_public_route_table"
  }
}

# Associate route table with the public subnet
resource "aws_route_table_association" "my_public_route_table_association" {
  subnet_id      = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.my_public_route_table.id
}

# Create security group allowing SSH and HTTP access
resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "my_security_group"
  }
}

# Create EC2 instance
resource "aws_instance" "my_ec2_instance" {
  ami                    = "ami-0e2c8caa4b6378d8c"  
  instance_type          = "t2.micro"      
  subnet_id              = aws_subnet.my_public_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]  
  associate_public_ip_address = true       # Assign public IP to EC2 instance
  key_name               = "newkey"  

  tags = {
    Name = "My EC2 Instance"
  }

  # User data to install Docker and run Nginx container
  user_data = <<-EOF
              #!/bin/bash
              # Update package list
              sudo apt-get update -y
              
              # Install Docker
              sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              sudo apt-get update -y
              sudo apt-get install -y docker-ce
              
              # Enable and start Docker service
              sudo systemctl enable docker
              sudo systemctl start docker
        
              
              # Pull Nginx image and run it in a container
              sudo docker pull nginx
              sudo docker run -d -p 80:80 --name nginx-container nginx
            EOF
}


# Output EC2 instance public IP
output "instance_public_ip" {
  value = aws_instance.my_ec2_instance.public_ip
}

# Output EC2 instance ID
output "instance_id" {
  value = aws_instance.my_ec2_instance.id
}

# Output VPC ID
output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

# Output Internet Gateway ID
output "internet_gateway_id" {
  value = aws_internet_gateway.my_igw.id
}

# Output Public Subnet ID
output "public_subnet_id" {
  value = aws_subnet.my_public_subnet.id
}

# Output Route Table ID
output "route_table_id" {
  value = aws_route_table.my_public_route_table.id
}

# Output Route Table Association ID
output "route_table_association_id" {
  value = aws_route_table_association.my_public_route_table_association.id
}

# Output Security Group ID
output "security_group_id" {
  value = aws_security_group.my_sg.id
}


