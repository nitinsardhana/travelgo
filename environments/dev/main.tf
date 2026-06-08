provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      Project     = "TravelGo"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr    = "10.0.0.0/16"
  environment = "dev"

  public_subnet_a_cidr = "10.0.1.0/24"
  public_subnet_b_cidr = "10.0.2.0/24"

  private_subnet_a_cidr = "10.0.11.0/24"
  private_subnet_b_cidr = "10.0.12.0/24"
}

module "security_groups" {
  source = "../../modules/security-groups"

  vpc_id      = module.vpc.vpc_id
  environment = "dev"
}

module "ec2" {
  source = "../../modules/ec2"

  environment = "dev"

  ami_id        = "ami-0067526cb10a5b138"
  instance_type = "t3.micro"

  subnet_id = module.vpc.public_subnet_a_id

  security_group_id = module.security_groups.web_security_group_id

  key_name = "travelgo-dev-key-v2"
}