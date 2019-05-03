provider "aws" {

  access_key = "${var.aws_access_key}"

  secret_key = "${var.aws_secret_key}"

  region     = "us-west-2"

}

 

variable "aws_access_key" {

    default = "AKIATFTJDVLEASYSZEWL"

}

variable "aws_secret_key" {

    default = "q+zuGxAw59u37EPU0QZMcglaQ8h1SdcBTVrBEvt/"

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

  availability_zone = "us-west-2a"
  
  depends_on = ["aws_vpc.Apache_VPC"]

  cidr_block = "10.0.1.0/24"

 

  tags {

    Name = "PublicSubnet"

  }

}

resource "aws_internet_gateway" "InternetGateway" {

  vpc_id = "${aws_vpc.Apache_VPC.id}"
  
  depends_on = ["aws_subnet.PublicSubnet"]

  tags {

    Name = "InternetGateway"

 }

}


resource "aws_route_table" "PublicRouteTable" {

  vpc_id = "${aws_vpc.Apache_VPC.id}"

  depends_on = ["aws_subnet.PublicSubnet"]

  tags {

    Name = "PublicRouteTable"

  }

}

resource "aws_route" "PublicRoute" {

  route_table_id = "${aws_route_table.PublicRouteTable.id}"

  destination_cidr_block = "0.0.0.0/0"
  
  depends_on = ["aws_route_table.PublicRouteTable"]

  gateway_id = "${aws_internet_gateway.InternetGateway.id}"

}

resource "aws_route_table_association" "PublicSubnetRouteTableAssociation" {

  subnet_id      = "${aws_subnet.PublicSubnet.id}"
  
  depends_on = ["aws_route_table.PublicRouteTable"]

  route_table_id = "${aws_route_table.PublicRouteTable.id}"

}

 

resource "aws_default_network_acl" "PublicSubnetNetworkAclAssociation" {

    default_network_acl_id = "${aws_vpc.Apache_VPC.default_network_acl_id}"

}

 

resource "aws_security_group" "WebServerSecurityGroup" {

  name        = "WebServerSecurityGroup"

  description = "Enable HTTP ingress"

  vpc_id = "${aws_vpc.Apache_VPC.id}"
  
  depends_on = ["aws_vpc.Apache_VPC"]

 

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

  security_groups = ["${aws_security_group.WebServerSecurityGroup.id}"]

  associate_public_ip_address = "true"

  subnet_id = "${aws_subnet.PublicSubnet.id}"     

  key_name = "demo" 
  
  user_data = <<HEREDOC
		#! /bin/bash
        sudo yum update -y
        sudo yum install httpd -y
		sudo service httpd start
		sudo chkconfig httpd on
		echo "<h1>First DevOps Demo in AWS using Terraform - Well Done ..!!</h1>" | sudo tee /var/www/html/index.html
	    HEREDOC

  tags {
    Name = "WebServer"
  }
  
} 