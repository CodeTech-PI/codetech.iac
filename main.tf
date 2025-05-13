terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
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

# scp -i keys/codetech_key.pem keys/codetech_key.pem ubuntu@{IP_BE}:/home/ubuntu/.ssh/codetech_key.pem
# scp -i keys/codetech_key.pem keys/codetech_key.pem ubuntu@{IP_BE2}:/home/ubuntu/.ssh/codetech_key.pem	
# ssh -i "keys/codetech_key.pem" ubuntu@{IP_BE}
# http://3.91.241.173/api/swagger-ui/index.html
# docker run -p 8080:8080 -d gabrielaseverino/codetech.api:v1
# docker logs $(docker ps -q --filter gabrielaseverino/codetech.api)