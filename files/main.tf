provider "aws" {
  region = "eu-central-2"
}

resource "aws_vpc" "default" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "gitlab-vault"
    owner = "Robert de Bock"
  }
}
