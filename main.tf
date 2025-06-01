provider "aws" {
  region = "us-east-1"  # Change this if you use a different region
}

# Use your existing public key for SSH access
resource "aws_key_pair" "my_key" {
  key_name   = "medicure-key"
  public_key = file("/home/ubuntu/project.pub")  # Change this path if needed
}

# Create a Security Group to allow SSH and app access
resource "aws_security_group" "my_sg" {
  name        = "medicure-sg"
  description = "Allow SSH and app access"

  ingress {
    from_port   = 22    # SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["3.83.135.215/32"]  # Allow from anywhere (or change to your IP)
  }

  ingress {
    from_port   = 8080  # App port
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"   # Allow all outbound
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "my_instance" {
  ami           = "ami-084568db4383264d4"  # Ubuntu 22.04 in us-east-1
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.my_sg.name]

  tags = {
    Name = "medicure-server"
  }
}

# Show public IP after deployment
output "instance_ip" {
  value = aws_instance.my_instance.public_ip
}

