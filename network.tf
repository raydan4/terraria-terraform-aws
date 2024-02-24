resource "aws_vpc" "terraria_vpc" {
    cidr_block = "192.168.1.0/24"

    tags = {
      Name = "Terraria VPC"
    }
}

resource "aws_subnet" "terraria_subnet" {
  vpc_id = aws_vpc.terraria_vpc.id
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "Terraria Subnet"
  }
}

resource "aws_internet_gateway" "terraria_internet_gateway" {
  vpc_id = aws_vpc.terraria_vpc.id
}

resource "aws_route_table" "terraria_public_route_table" {
  vpc_id = aws_vpc.terraria_vpc.id
  route = [{
    carrier_gateway_id = null
    cidr_block = "0.0.0.0/0"
    core_network_arn = null
    destination_prefix_list_id = null
    egress_only_gateway_id = null
    gateway_id = aws_internet_gateway.terraria_internet_gateway.id
    ipv6_cidr_block = null
    local_gateway_id = null
    nat_gateway_id = null
    network_interface_id = null
    transit_gateway_id = null
    vpc_endpoint_id = null
    vpc_peering_connection_id = null
  }]

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "terraria_submet_route_table_association" {
  route_table_id = aws_route_table.terraria_public_route_table.id
  subnet_id = aws_subnet.terraria_subnet.id
}

resource "aws_security_group" "allow_terraria_server" {
  name = "allow-terraria-server"
  description = "Allow inbound terraria server traffic"
  vpc_id = aws_vpc.terraria_vpc.id

  ingress {
    description = "Terraria Protocol"
    from_port = var.terraria_config_port
    to_port = var.terraria_config_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Allow Terraria"
  }
}

resource "aws_security_group" "allow_ssh" {
  name = "allow-terraria-ssh"
  description = "Allow inbound terraria server ssh traffic"
  vpc_id = aws_vpc.terraria_vpc.id

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Allow SSH"
  }
}
