terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
     tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

variable "region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

module "network" {
  source = "./network"
}

module "instances" {
  source              = "./instances"
  vpc_id              = module.network.vpc_id
  subnet_publica_id   = module.network.subnet_publica_id
  subnet_private_id   = module.network.subnet_private_id
  security_public_id  = module.network.security_public_id
  security_private_id = module.network.security_private_id
}

resource "aws_eip" "ip_instancia-publica" {
  vpc = true

  tags = {
    Name = "codetech-ip-publico"
  }
}

resource "aws_eip_association" "assoc_ip_publica" {
  instance_id   = module.instances.public_instance_id
  allocation_id = aws_eip.ip_instancia-publica.id
}