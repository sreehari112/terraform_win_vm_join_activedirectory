terraform {
  required_providers {
    aws = {
      source  = "HASHICORP/AWS"
      version = "~> 3.58"
    }
  }
  required_version = ">= 0.15.0"
}


provider "aws" {
  region = "us-west-2"
}

module "vm" {
  source = "./modules/vm"
  win_ami   = var.win_ami
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_id = var.vpc_id
  security_group_name = var.security_group_name
  ingress_rules = var.ingress_rules 
}
