terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket         = "nikko-terraform-state-bucket-7x9k2m"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "prod"
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

locals {
  environment = "prod"
  common_tags = {
    Environment = local.environment
    Project     = var.project_name
  }
}

module "vpc" {
  source = "../../modules/vpc"

  environment          = local.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  enable_nat_gateway   = var.enable_nat_gateway

  tags = local.common_tags
}

module "security_groups" {
  source = "../../modules/security-groups"

  environment       = local.environment
  vpc_id            = module.vpc.vpc_id
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
  app_port          = var.app_port
  db_port           = var.db_port
  create_bastion_sg = var.create_bastion
  create_web_sg     = var.create_web_servers
  create_app_sg     = var.create_app_servers
  create_db_sg      = var.create_db_servers

  tags = local.common_tags
}

module "iam" {
  source = "../../modules/iam"

  environment       = local.environment
  enable_ssm        = var.enable_ssm
  enable_cloudwatch = var.enable_cloudwatch
  enable_s3_read    = var.enable_s3_read
  s3_bucket_arns    = var.s3_bucket_arns

  tags = local.common_tags
}

module "bastion" {
  source = "../../modules/ec2"
  count  = var.create_bastion ? 1 : 0

  environment           = local.environment
  instance_name         = "bastion"
  instance_count        = 1
  instance_type         = var.bastion_instance_type
  subnet_ids            = module.vpc.public_subnet_ids
  security_group_ids    = [module.security_groups.bastion_sg_id]
  instance_profile_name = module.iam.ec2_instance_profile_name
  key_name              = var.key_name
  associate_elastic_ip  = true

  tags = local.common_tags
}

module "web_servers" {
  source = "../../modules/ec2"
  count  = var.create_web_servers ? 1 : 0

  environment                = local.environment
  instance_name              = "web"
  instance_count             = var.web_instance_count
  instance_type              = var.web_instance_type
  subnet_ids                 = module.vpc.public_subnet_ids
  security_group_ids         = [module.security_groups.web_sg_id]
  instance_profile_name      = module.iam.ec2_instance_profile_name
  key_name                   = var.key_name
  user_data                  = var.web_user_data
  enable_detailed_monitoring = true

  tags = local.common_tags
}

module "app_servers" {
  source = "../../modules/ec2"
  count  = var.create_app_servers ? 1 : 0

  environment                = local.environment
  instance_name              = "app"
  instance_count             = var.app_instance_count
  instance_type              = var.app_instance_type
  subnet_ids                 = module.vpc.private_subnet_ids
  security_group_ids         = [module.security_groups.app_sg_id]
  instance_profile_name      = module.iam.ec2_instance_profile_name
  key_name                   = var.key_name
  user_data                  = var.app_user_data
  enable_detailed_monitoring = true

  tags = local.common_tags
}
