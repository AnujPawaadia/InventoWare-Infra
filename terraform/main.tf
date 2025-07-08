module "vpc" {
  source               = "./modules/vpc"
  project              = var.project
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  azs                  = ["eu-north-1a", "eu-north-1b"]
}
module "security_groups" {
  source               = "./modules/security_groups"
  project              = var.project
  vpc_id               = module.vpc.vpc_id
  bastion_allowed_cidr = var.bastion_allowed_cidr
}
module "alb" {
  source            = "./modules/alb"
  project           = var.project
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security_groups.alb_sg_id
  app_port          = var.app_port
}

module "asg" {
  source             = "./modules/asg"
  project            = var.project
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  key_name           = var.key_name
  instance_profile   = module.iam.instance_profile_name
  instance_sg_id     = module.security_groups.instance_sg_id
  private_subnet_ids = module.vpc.private_subnet_ids
  blue_tg_arn        = module.target_groups.blue_target_group_arn
  green_tg_arn       = module.target_groups.green_target_group_arn
  azs                = var.azs # <-- add this line
}
module "iam" {
  source  = "./modules/iam"
  project = var.project
}
module "cloudwatch" {
  source  = "./modules/cloudwatch"
  project = var.project
  aws_region  = var.aws_region
}
module "target_groups" {
  source   = "./modules/target_groups"
  project  = var.project
  vpc_id   = module.vpc.vpc_id
  app_port = var.app_port
}


module 
module "alb_listener" {
  source                = "./modules/alb_listener"
  alb_arn               = module.alb.alb_arn
  blue_target_group_arn = module.target_groups.blue_target_group_arn
}

module "bastion_host" {
  source           = "./modules/bastion_host"
  project          = var.project
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  key_name         = var.key_name
  public_subnet_id = module.vpc.public_subnet_ids[0]
  bastion_sg_id    = module.security_groups.bastion_sg_id
}

