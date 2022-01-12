terraform {
  required_version = ">=1.1.3"
}

provider "aws" {
  region = "us-west-2"
}

data "aws_ami" "debian" {
  most_recent = true
  filter {
    name   = "name"
    values = ["debian-10-amd64-20211011-*"]
  }
  owners = ["136693071363"] #Debian Buster [https://wiki.debian.org/Cloud/AmazonEC2Image/Buster]
}

resource "random_uuid" "server_name" {}


resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "Project_Zomboid-${random_uuid.server_name.result}"
        Game = "Project_Zomboid"
    }
}

resource "aws_subnet" "subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.1.0/24"
    tags = {
        Name = "Project_Zomboid-${random_uuid.server_name.result}"
        Game = "Project_Zomboid"
    }
}

resource "aws_network_interface" "nic" {
    subnet_id = aws_subnet.subnet.id
    private_ips = ["10.0.1.100"]
    tags = {
        Name = "Project_Zomboid-${random_uuid.server_name.result}"
        Game = "Project_Zomboid"
    }
}


resource "aws_instance" "web" {
  ami           = data.aws_ami.debian.id
  instance_type = "t2.medium"

  tags = {
    Name = "Project_Zomboid-${random_uuid.server_name.result}"
    Game = "Project_Zomboid"
  }

  network_interface {
      network_interface_id = aws_network_interface.nic.id
      device_index = 0
  }
}