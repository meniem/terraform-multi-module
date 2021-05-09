
# Configure the storage for storing the state
terraform {
  required_version = "0.15.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.39"
    }
  }

  backend "s3" {
    bucket         = "challenge-task-terraform-state-us-east-1"
    key            = "tf_task.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_state"
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  aws_region  = var.aws_region
  environment = var.environment
  tags        = var.tags
}

module "ec2" {
  source = "./modules/ec2"

  aws_region  = var.aws_region
  environment = var.environment
  tags        = var.tags

  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
}

module "rds" {
  source = "./modules/rds"

  aws_region  = var.aws_region
  environment = var.environment
  tags        = var.tags

  vpc_id          = module.vpc.vpc_id
  vpc_cidr        = module.vpc.vpc_cidr
  private_subnets = module.vpc.private_subnets
}

module "eks" {
  source = "./modules/eks"

  aws_region  = var.aws_region
  environment = var.environment
  tags        = var.tags

  vpc_id                    = module.vpc.vpc_id
  vpc_cidr                  = module.vpc.vpc_cidr
  private_subnets           = module.vpc.private_subnets
  eks_cluster_iam_role_name = module.iam.eks_cluster_iam_role_name
  node_group_iam_role_arn   = module.iam.node_group_iam_role_arn
}

module "iam" {
  source = "./modules/iam"

  aws_region  = var.aws_region
  environment = var.environment
  tags        = var.tags
}



