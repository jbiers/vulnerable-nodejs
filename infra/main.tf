terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
      }
    }
}

locals {
  common_tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "5.0.0"

    name = "my-vpc"
    cidr = "10.0.0.0/16"

    azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] 
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

    enable_nat_gateway = false

    tags = local.common_tags
}

data "aws_ami" "amazon_linux" {
    most_recent = true

    owners = ["amazon"]

    filter {
        name = "name"

        values = [
            "amzn2-ami-hvm-*-x86_64-gp2",
        ]
    }

    filter {
        name = "owner-alias"

        values = [
            "amazon",
        ]
    }
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.amazon_linux
  instance_type = "t3.nano"
  subnet_id     = element(module.vpc.private_subnets, 0)
}

module "alb" {
    source  = "terraform-aws-modules/alb/aws"
    version = "8.7.0"

    name = "web-app"

    load_balancer_type = "application"

    vpc_id  = module.vpc.default_vpc_id
    subnets = module.vpc.public_subnets

    target_groups = [
        {
            name_prefix      = "pref-"
            backend_protocol = "HTTP"
            backend_port     = "80"
            target_type      = "instance"
            targets = {
                my_ec2 = {
                    target_id = aws_instance.this.id
                    port = 8080
                }
            }
        }
    ]

    http_tcp_listeners = [
        {
            port               = 80
            protocol           = "HTTP"
            target_group_index = 0
        }
    ]

    tags = local.common_tags
}