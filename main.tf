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

resource "aws_key_pair" "ssh_key" {
  key_name = "pz_ssh_key"
  public_key = var.public_ssh_key

  tags = {
    Name = "Project_Zomboid-${random_uuid.server_name.result}"
    Game = "Project_Zomboid"
  }
}


/*
 Network Start
*/ 
resource "aws_route" "route_ign_to_vpc" {
  route_table_id = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = var.cidr_block
  gateway_id = aws_internet_gateway.gw.id
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags = {
      Name = "Project_Zomboid-${random_uuid.server_name.result}"
      Game = "Project_Zomboid"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
      Name = "Project_Zomboid-${random_uuid.server_name.result}"
      Game = "Project_Zomboid"
  }
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

  tags = {
    Name = "Project_Zomboid-${random_uuid.server_name.result}"
    Game = "Project_Zomboid"
  }
}

/*
 Network End
*/

resource "aws_instance" "pz_server" {
  ami           = data.aws_ami.debian.id
  instance_type = "t2.medium"

  private_ip = "10.0.1.100"

  tags = {
    Name = "Project_Zomboid-${random_uuid.server_name.result}"
    Game = "Project_Zomboid"
  }

  subnet_id = aws_subnet.subnet.id

  key_name = "pz_ssh_key"

  security_groups = [aws_security_group.security_group]
}

resource "aws_security_group" "security_group" {
  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
  }
  ingress {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
  }
  egress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
  }
  egress {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
  }

  tags = {
      Name = "Project_Zomboid-${random_uuid.server_name.result}"
      Game = "Project_Zomboid"
  }
}