resource "aws_vpc" "terraform-vpc" {
  cidr_block = "10.0.0.0/16"  #enter CIDR block

  tags = {
    Name = "Terraform-VPC"    #enter VPC name
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = "${aws_vpc.terraform-vpc.id}"
  cidr_block = "10.0.1.0/24"    #enter CIDR block

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = "${aws_vpc.terraform-vpc.id}"
  cidr_block = "10.0.2.0/24"    #enter CIDR block

  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_security_group" "terraform-sg" {
  name        = "Terraform-SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.terraform-vpc.id}"

  ingress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform-SG"
  }
}

resource "aws_internet_gateway" "terraform-igw" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"

  tags = {
    Name = "Terraform-IGW"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.terraform-igw.id}"
  }

  tags = {
    Name = "Public RT"
  }
}

resource "aws_route_table_association" "public-rt-asso" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_instance" "web-server" {
  ami           = "ami-06ca3ca175f37dd66" # Amazon Linux 2023 AMI
  instance_type = "t2.micro"
  key_name = "" # enter key-file name
  subnet_id = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.terraform-sg.id]

  connection {
    type = "ssh"
    host = self.public_ip
    user = ec2-user
    private_key = file("") # key-file path
  }

  tags = {
    Name = "Web Server"
  }
}

resource "aws_eip" "terraform-aws-eip" {
  instance = "${aws_instance.web-server.id}"
  vpc      = true
}

resource "aws_instance" "db-server" {
  ami           = "ami-06ca3ca175f37dd66" # Amazon Linux 2023 AMI
  instance_type = "t2.micro"
  key_name = "" #enter key-file name
  subnet_id = aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws_security_group.terraform-sg.id]

  connection {
    type = "ssh"
    #host = self.public_ip
    user = ec2-user
    private_key = file("") # key-file path
  }

  tags = {
    Name = "Database Server"
  }
}

resource "aws_eip" "terraform-aws-ngw-id" {
  vpc      = true
}

resource "aws_nat_gateway" "aws-ngw" {
  allocation_id = aws_eip.terraform-aws-ngw-id.id
  subnet_id     = "${aws_subnet.public-subnet.id}"

  tags = {
    Name = "NAT Gateway"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.aws-ngw.id}"
  }
  
  tags = {
    Name = "Private-RT"
  }
}

resource "aws_route_table_association" "private-rt-asso" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}
