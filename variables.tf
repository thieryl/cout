variable "region" {
  default = "eu-west-2"
}
variable "AmiLinux" {
  type = "map"
  default = {
    eu-west-1 = "ami-24506250" # Ireland
    eu-west-2 = "ami-896369ed" # London
  }
  description = "I add only 2 regions Ireland and london, to show the map feature but you can add all the regions that you need"
}
/*
variable "aws_access_key" {
  default = ""
  description = "the user aws access key"
}

variable "aws_secret_key" {
  default = ""
  description = "the user aws secret key"
}
*/

variable "aws_profile" {
  default = "rbd_sys"
  description = "the aws profile to be used"
}

variable "credentialsfile" {
  default = "/Users/thieryl/.aws/credentials" #replace your home directory
  description = "where your access and secret_key are stored, you create the file when you run the aws config"
}

variable "vpc-fullcidr" {
    default = "172.28.0.0/16"
  description = "the vpc cdir"
}
variable "Subnet-Public-AzA-CIDR" {
  default = "172.28.0.0/24"
  description = "the cidr of the subnet"
}
variable "Subnet-Private-AzA-CIDR" {
  default = "172.28.3.0/24"
  description = "the cidr of the subnet"
}
variable "key_name" {
  default = "cout"
  description = "the ssh key to use in the EC2 machines"
}
variable "DnsZoneName" {
  default = "tricky-bit.internal"
  description = "the internal dns name"
}
