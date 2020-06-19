variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "aws_amis" {
    description = "AMIs by region"
    default = {
    eu-west-1 = "ami-0701e7be9b2a77600" # ubuntu 18.04 LTS
    eu-west-2 = "ami-0eb89db7593b5d434" # ubuntu 18.04 LTS
		}
}
variable "private_amis" {
    description = "AMIs by region"
    default = {
    eu-west-1 = "ami-0b4b2d87bdd32212a" # Amazon Linux 1
    eu-west-2 = "ami-0330ffc12d7224386" # Amazon Linux 1
		}
}
variable "vpc_cidr" {}
variable "vpc_name" {}
variable "IGW_name" {}
variable "key_name" {}

variable Main_Routing_Table {}

variable "publicazs" {
  description = "Zones for Public Subnets"
  type = "list"
  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}
  variable "privateazs" {
  description = "Zones for Private Subnets"
  type = "list"
  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}
variable "publiccidrs" {
  description = "Zones for Public cidrs"
  type = "list"
  default = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
}
variable "privatecidrs" {
  description = "Zones for Private cidrs"
  type = "list"
  default = ["172.16.10.0/24", "172.16.20.0/24", "172.16.30.0/24"]
}
variable "environment" { default = "dev" }
variable "instance_type" {
  type = "map"
  default = {
    dev = "t2.micro"
    }
}


