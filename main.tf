terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.3.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "MarketplaceDemoVPC"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id    = aws_vpc.my_vpc.id
  tags = {
    Name = "MarketplaceIGW"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.3.10.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "MarketplaceDemoSubnet"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

    ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "RouteTableMarketplace"
  }
}

resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["10.3.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "foo" {
  ami           = "ami-0747bdcabd34c712a"
  instance_type = "t2.micro"
  key_name      = "8June"
  #  vpc_security_group_ids = aws_security_group.allow_all.id

  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo -s",
      "git clone https://github.com/alik116/TerraformDocker_Marketplace.git",
      "cd TerraformDocker_Marketplace"
      "chmod +x run.sh"
      "./run.sh"
    ]
  }

}