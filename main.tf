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
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
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

resource "aws_route" "route_ign_to_vpc" {
  route_table_id = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_subnet" "subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = "us-west-2a"
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

resource "aws_security_group" "security_group" {

  vpc_id = aws_vpc.vpc.id
  #Allow all inbound
  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "PZserver Port"
    from_port = 8766
    to_port = 8766
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "PZserver Port"
    from_port = 16261
    to_port = 16261
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Allow all outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
      Name = "Project_Zomboid-${random_uuid.server_name.result}"
      Game = "Project_Zomboid"
  }
}

data aws_route53_zone "DNSZone"{
  name = "seanboyer.us"
}
resource aws_route53_record  "mcDNSRecord" {
  zone_id = data.aws_route53_zone.DNSZone.zone_id
  name = "pzold.seanboyer.us"
  type = "A"
  ttl = "300"
  records = [
    aws_eip.eip.public_ip
  ]
}

/*
 Network End
*/

resource "aws_instance" "pz_server" {
  ami           = data.aws_ami.debian.id
  availability_zone = "us-west-2a"
  instance_type = "t2.medium"

  private_ip = "10.0.1.100"

  tags = {
    Name = "Project_Zomboid-${random_uuid.server_name.result}"
    Game = "Project_Zomboid"
  }

  subnet_id = aws_subnet.subnet.id

  key_name = "pz_ssh_key"

  vpc_security_group_ids = [aws_security_group.security_group.id]

  provisioner "file" {
    source      = "installPZServerViaLinuxGSM.sh"
    destination = "/tmp/installScript.sh"

    connection {
      type = "ssh"
      private_key = var.private_ssh_key
      user = var.ssh_user
      host = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/installScript.sh",
      "/tmp/installScript.sh ${var.password} >> /tmp/installScript.txt",
    ]

    connection {
      type = "ssh"
      private_key = var.private_ssh_key
      user = var.ssh_user
      host = self.public_ip
    }
  }
}