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

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.1.0/24"

     map_public_ip_on_launch = true


     depends_on = [aws_internet_gateway.gw]
    tags = {
        Name = "Project_Zomboid-${random_uuid.server_name.result}"
        Game = "Project_Zomboid"
    }
}

resource "aws_eip" "eip" {
  instance = aws_instance.pz_server.id
  vpc = true
  associate_with_private_ip = "10.0.1.100"
  depends_on                = [aws_internet_gateway.gw]
}

resource "aws_instance" "pz_server" {
  ami           = data.aws_ami.debian.id
  instance_type = "t2.medium"

  private_ip = "10.0.1.100"

  tags = {
    Name = "Project_Zomboid-${random_uuid.server_name.result}"
    Game = "Project_Zomboid"
  }

  subnet_id = aws_subnet.subnet.id

  key_name = aws_key_pair.ssh_key
}
resource "aws_key_pair" "ssh_key" {
  key_name = "ssh-key"
  public_key = var.public_ssh_key

    tags = {
    Name = "Project_Zomboid-${random_uuid.server_name.result}"
    Game = "Project_Zomboid"
  }
}