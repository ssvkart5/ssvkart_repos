#This Terraform Code Deploys Basic VPC Infra.
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags = {
    Name  = "${var.vpc_name}"
    Owner = "ssvkart"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
  tags = {
    Name = "${var.IGW_name}"
  }
}

resource "aws_subnet" "publicsubnets" {
  count             = "${length(var.publicazs)}"
  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${element(var.publicazs, count.index)}"
  cidr_block        = "${element(var.publiccidrs, count.index)}"

  tags = {
    Name = "Public_subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "privatesubnets" {
  count             = "${length(var.privateazs)}"
  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${element(var.privateazs, count.index)}"
  cidr_block        = "${element(var.privatecidrs, count.index)}"

  tags = {
    Name = "Private_subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "Publicrt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags = {
    Name = "Public routing table"
  }
}
resource "aws_route_table" "Privatert" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.natgw.id}"
  }

  tags = {
    Name = "Private routing table"
  }
}

resource "aws_route_table_association" "terraform-public" {
  count          = "${length(var.publicazs)}"
  subnet_id      = "${element(aws_subnet.publicsubnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.Publicrt.id}"
}
resource "aws_route_table_association" "terraform-private" {
  count          = "${length(var.privateazs)}"
  subnet_id      = "${element(aws_subnet.privatesubnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.Privatert.id}"
}
resource "aws_eip" "natgw-eip" {
}
resource "aws_nat_gateway" "natgw" {
  allocation_id = "${aws_eip.natgw-eip.id}"
  subnet_id     = "${aws_subnet.publicsubnets.1.id}"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#data "aws_ami" "my_ami" {
#  most_recent = false
#  owners = ["519038273189"]
#}



resource "aws_instance" "publicservers" {
  # ami = "${data.aws_ami.my_ami.id}"
  count = "${length(var.publicazs)}"   # To create on all public subnets
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  #availability_zone           = "eu-west-2a"
  instance_type               = "t2.micro"
  key_name                    = "key"
  #subnet_id                   = "${aws_subnet.subnet1-public.id}"
  subnet_id = "${element(aws_subnet.publicsubnets.*.id, count.index)}"
  vpc_security_group_ids      = ["${aws_security_group.allow_all.id}"]
  associate_public_ip_address = true
  tags = {
    Name       = "public-ssvkart-${count.index+1}"
    Env        = "Dev"
    Owner      = "ssvkart"
    CostCenter = "ABCD"
  }
}

resource "aws_instance" "privateservers" {
  count = 2    # If we want only two servers
  ami = "${lookup(var.private_amis, var.aws_region)}"
  instance_type               = "t2.micro"
  key_name                    = "key"
  subnet_id = "${element(aws_subnet.privatesubnets.*.id, count.index)}"
  vpc_security_group_ids      = ["${aws_security_group.allow_all.id}"]
  associate_public_ip_address = true
  tags = {
    Name       = "private-ssvkart-${count.index+1}"
    Env        = "Dev"
    Owner      = "ssvkart"
    CostCenter = "ABCD"
  }
}
#output "ami_id" {
#  value = "${data.aws_ami.my_ami.id}"
#}
#!/bin/bash
# echo "Listing the files in the repo."
#ls -al
#echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
#echo "Running Packer Now...!!"
#packer build -var=aws_access_key=AAAAAAAAAAAAAAAAAA -var=aws_secret_key=BBBBBBBBBBBBB packer.json
#echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
#echo "Running Terraform Now...!!"
#terraform init
#terraform apply --var-file terraform.tfvars -var="aws_access_key=AAAAAAAAAAAAAAAAAA" -var="aws_secret_key=BBBBBBBBBBBBB" --auto-approve
