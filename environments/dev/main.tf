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

module "alb" {
  source = "../../modules/alb"

  environment = "dev"

  vpc_id = module.vpc.vpc_id

  public_subnet_a_id = module.vpc.public_subnet_a_id
  public_subnet_b_id = module.vpc.public_subnet_b_id
}

module "launch_template" {
  source = "../../modules/launch-template"

  environment = "dev"

  ami_id        = "ami-0067526cb10a5b138"
  instance_type = "t3.micro"

  security_group_id = module.security_groups.web_security_group_id

  key_name = "travelgo-dev-key-v2"
}

module "asg" {
  source = "../../modules/asg"

  environment = "dev"

  launch_template_id      = module.launch_template.launch_template_id
  launch_template_version = module.launch_template.launch_template_latest_version

  public_subnet_a_id = module.vpc.public_subnet_a_id
  public_subnet_b_id = module.vpc.public_subnet_b_id

  target_group_arn = module.alb.target_group_arn
}


resource "aws_security_group_rule" "ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = module.security_groups.web_security_group_id
}

resource "aws_security_group_rule" "https" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = module.security_groups.web_security_group_id
}

resource "aws_security_group_rule" "alb_to_ec2_http" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  security_group_id        = module.security_groups.web_security_group_id
  source_security_group_id = module.alb.alb_security_group_id
}