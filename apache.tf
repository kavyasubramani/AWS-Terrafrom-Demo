provider "aws" {

  access_key = "${var.aws_access_key}"

  secret_key = "${var.aws_secret_key}"

  region     = "us-west-2"

}

 

variable "aws_access_key" {

    default = "AKIAI73VHOZO5VM7ZCRA"

}

variable "aws_secret_key" {

    default = "RUqskujkqY8EkzcgXwLPXxzUgoG3wMcG5w7jJ1MF"

}

 

resource "aws_vpc" "Apache_VPC" {

  cidr_block       = "10.0.0.0/16"

  enable_dns_support = "true"

  enable_dns_hostnames ="true"

 

  tags {

    Name = "Apache_VPC"

  }

}

resource "aws_subnet" "PublicSubnet" {

  vpc_id     = "${aws_vpc.Apache_VPC.id}"

  cidr_block = "10.0.1.0/24"

 

  tags {

    Name = "PublicSubnet"

  }

}

resource "aws_internet_gateway" "InternetGateway" {

  vpc_id = "${aws_vpc.Apache_VPC.id}"

 

  tags {

    Name = "InternetGateway"

  }

}

resource "aws_vpn_gateway_attachment" "VPCGatewayAttachment" {

  vpc_id = "${aws_vpc.Apache_VPC.id}"

  vpn_gateway_id = "${aws_internet_gateway.InternetGateway.id}"

}

resource "aws_route_table" "PublicRouteTable" {

  vpc_id = "${aws_vpc.Apache_VPC.id}"

 

  tags {

    Name = "PublicRouteTable"

  }

}

resource "aws_route" "PublicRoute" {

  route_table_id = "${aws_route_table.PublicRouteTable.id}"

  destination_cidr_block = "0.0.0.0/0"

  gateway_id = "${aws_internet_gateway.InternetGateway.id}"

}

resource "aws_route_table_association" "PublicSubnetRouteTableAssociation" {

  subnet_id      = "${aws_subnet.PublicSubnet.id}"

  route_table_id = "${aws_route_table.PublicRouteTable.id}"

}

 

resource "aws_default_network_acl" "PublicSubnetNetworkAclAssociation" {

    default_network_acl_id = "${aws_vpc.Apache_VPC.default_network_acl_id}"

}

 

resource "aws_security_group" "WebServerSecurityGroup" {

  name        = "WebServerSecurityGroup"

  description = "Enable HTTP ingress"

  vpc_id = "${aws_vpc.Apache_VPC.id}"

 

  ingress {

    from_port   = 80

    to_port     = 80

    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

    ingress {

    from_port   = 22

    to_port     = 22

    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

 

  tags {

    Name = "WebServerSecurityGroup"

  }

}

 

resource "aws_instance" "WebServerInstance" {

  ami           = "ami-a0cfeed8"

  instance_type = "t2.micro"

  #vpc_security_group_ids = "${aws_security_group.WebServerSecurityGroup}"

  associate_public_ip_address = "true"

  subnet_id = "${aws_security_group.WebServerSecurityGroup.id}"

  key_name = "AWSHome"       

  tags {

    Name = "WebServerInstance"

  }

  user_data = <<HEREDOC

                sudo yum update -y

                sudo yum install httpd -y

                sudo /etc/init.d/httpd start

                echo \"<html><body><h1>Antony - It's your first Terraform!!!</h1>\" > /var/www/html/index.html

                echo \"</body></html>\" >> /var/www/html/index.html"

                HEREDOC

}