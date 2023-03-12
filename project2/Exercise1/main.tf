provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "udacity_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Udacity VPC",
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.udacity_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "sg_public" {
  name_prefix = "sg_public"
  vpc_id      = aws_vpc.udacity_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "udacity_t2" {
  count         = 4
  ami           = "ami-005f9685cb30f234b"
  instance_type = "t2.micro"
  key_name      = "udacity_key"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.sg_public.id]
  tags = {
    Name = "Udacity T2"
  }
}

# resource "aws_instance" "udacity_m4" {
#   count         = 2
#   ami           = "ami-005f9685cb30f234b"
#   instance_type = "m4.large"
#   key_name      = "udacity_key"
#   subnet_id     = aws_subnet.public_subnet.id
#   vpc_security_group_ids = [aws_security_group.sg_public.id]
#   tags = {
#     Name = "Udacity M4"
#   }
# }