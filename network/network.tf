//  Define the VPC.
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}" // i.e. 10.0.0.0 to 10.0.255.255
  enable_dns_hostnames = true
  tags {
    Name    = "${var.project_name}-${var.env_name}-vpc"
    Project = "${var.project_name}"
  }
}

//  Create an Internet Gateway for the VPC.
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name    = "${var.project_name}-${var.env_name}-internet-gateway"
    Project = "${var.project_name}"
  }
}

//  Create public and private subnets for each AZ.
resource "aws_subnet" "public_a" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.public_subnet_cidr1}" // i.e. 10.0.1.0 to 10.0.1.255
  availability_zone       = "${var.subnetaz1}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.gw"]

  tags {
    Name    = "${var.project_name}-${var.env_name}-public-subnet-a"
    Project = "${var.project_name}"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.private_subnet_cidr1}" // i.e. 10.0.1.0 to 10.0.1.255
  availability_zone       = "${var.subnetaz1}"

  tags = {
    Name    = "${var.project_name}-${var.env_name}-private-subnet-a"
    Project = "${var.project_name}"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.public_subnet_cidr2}" // i.e. 10.0.12.0 to 10.0.12.255
  availability_zone       = "${var.subnetaz2}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.gw"]

  tags {
    Name    = "${var.project_name}-${var.env_name}-public-subnet-b"
    Project = "${var.project_name}"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.private_subnet_cidr2}" // i.e. 10.0.2.0 to 10.0.2.255
  availability_zone       = "${var.subnetaz2}"

  tags = {
    Name    = "${var.project_name}-${var.env_name}-private-subnet-b"
    Project = "${var.project_name}"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.public_subnet_cidr3}" // i.e. 10.0.13.0 to 10.0.13.255
  availability_zone       = "${var.subnetaz3}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.gw"]

  tags {
    Name    = "${var.project_name}-${var.env_name}-public-subnet-c"
    Project = "${var.project_name}"
  }
}

resource "aws_subnet" "private_c" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.private_subnet_cidr3}" // i.e. 10.0.3.0 to 10.0.3.255
  availability_zone       = "${var.subnetaz3}"

  tags = {
    Name    = "${var.project_name}-${var.env_name}-private-subnet-c"
    Project = "${var.project_name}"
  }
}

// Create an Elastic ip for the NAT
resource "aws_eip" "nat_eip" {
  vpc      = true
  depends_on = ["aws_internet_gateway.gw"]
}

// Create the NAT Gateways
resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = "${aws_eip.nat_eip.id}"
    subnet_id = "${aws_subnet.public_a.id}"
    depends_on = ["aws_internet_gateway.gw"]
}

//  Create a route table allowing all addresses access to the IGW.
resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name    = "${var.project_name}-${var.env_name}-public-route-table"
    Project = "${var.project_name}"
  }
}

//  Now associate the route table with the public subnet - giving
//  all public subnet instances access to the internet.
resource "aws_route_table_association" "public_a" {
  subnet_id      = "${aws_subnet.public_a.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = "${aws_subnet.public_b.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = "${aws_subnet.public_c.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

//  Create a PRIVATE route table allowing all addresses access to the IGW.
resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name    = "${var.project_name}-${var.env_name}-private-route-table"
    Project = "${var.project_name}"
  }
}

resource "aws_route" "private_route" {
	route_table_id  = "${aws_route_table.private_route_table.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.nat_gateway.id}"
}

//  Now associate the route table with the public subnet - giving
//  all public subnet instances access to the internet.
resource "aws_route_table_association" "private_a" {
  subnet_id      = "${aws_subnet.private_a.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = "${aws_subnet.private_b.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = "${aws_subnet.private_c.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

//  Create an internal security group for the VPC, which allows everything in the VPC
//  to talk to everything else.
resource "aws_security_group" "vpc_sg" {
  name        = "${var.project_name}-${var.env_name}-vpc-security-group"
  description = "Default security group that allows inbound and outbound traffic from all instances in the VPC"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "4140"
    to_port     = "4140"
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "${var.project_name}-${var.env_name}-vpc-security-group"
    Project = "${var.project_name}"
  }
}

//  Create a security group allowing web access to the public subnet.
resource "aws_security_group" "public_web_sg" {
  name        = "${var.project_name}-${var.env_name}-public-web-security-group"
  description = "Security group that allows web traffic from internet"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  Linkerd
  ingress {
    from_port   = 4140
    to_port     = 4140
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  The Consul admin UI is exposed over 8500...
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  The linkerd admin UI is exposed over 9990...
  ingress {
    from_port   = 9990
    to_port     = 9990
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "${var.project_name}-${var.env_name}-public-web-security-group"
    Project = "${var.project_name}"
  }
}

//  Create a security group allowing web access to the public subnet.
resource "aws_security_group" "fox_web_sg" {
  name        = "${var.project_name}-${var.env_name}-fox-web-security-group"
  description = "Security group that allows web traffic from internal locations"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0", # temporarily allow everywhere until we are ready
      "216.205.235.0/24", # fox family
      "216.205.224.0/24", # fox friends
      "24.24.137.137/32",  # brian home
      "178.43.72.243/32"   # mateusz
    ]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["216.205.235.0/24","216.205.224.0/24"]
  }

  tags {
    Name    = "${var.project_name}-${var.env_name}-fox-web-security-group"
    Project = "${var.project_name}"
  }
}

//  Create a security group which allows ssh access from the web.
//  Remember: This is *not* secure for production! In production, use a Bastion.
resource "aws_security_group" "public_ssh_sg" {
  name        = "${var.project_name}-${var.env_name}-public-ssh-security-group"
  description = "Security group that allows SSH traffic from internet"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "${var.project_name}-${var.env_name}-public-ssh-security-group"
    Project = "${var.project_name}"
  }
}

resource "aws_eip" "bastion_eip" {
  vpc         = true
}
