terraform {
  backend "s3" {
    bucket         = "terraform-state-og-1"
    key            = "production/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "myapp"
      ManagedBy   = "terraform"
    }
  }
}

module "networking" {
  source = "../../modules/networking"

  environment        = var.environment
  vpc_cidr          = var.vpc_cidr
  high_availability = true
  tags              = local.tags
}

module "alb" {
  source = "../../modules/alb"

  environment     = var.environment
  vpc_id         = module.networking.vpc_id
  public_subnets = module.networking.public_subnets
  tags           = local.tags
}

module "ecs" {
  source = "../../modules/ecs"

  environment      = var.environment
  vpc_id          = module.networking.vpc_id
  private_subnets = module.networking.private_subnets
  alb_sg_id       = module.alb.alb_sg_id
  target_group_arn = module.alb.target_group_arn
  container_image = var.container_image
  service_count   = var.service_count
  task_cpu        = var.task_cpu
  task_memory     = var.task_memory
  tags            = local.tags
  db_endpoint = module.database.db_instance_endpoint
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}

module "database" {
  source = "../../modules/database"

  environment         = var.environment
  vpc_id             = module.networking.vpc_id
  db_subnet_group_name = module.networking.database_subnet_group_name
  app_sg_id          = module.ecs.app_sg_id
  
  engine_version     = var.engine_version
  instance_class     = var.instance_class
  allocated_storage  = var.allocated_storage
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  multi_az           = true  # Enable high availability for production
  
  backup_retention_period = var.backup_retention_period
  tags                   = local.tags
}