provider "aws" {
  region = var.region
}

module "networking" {
  source = "./modules/networking"

  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  project_name         = var.project_name
}

module "security" {
  source = "./modules/security"

  vpc_id              = module.networking.vpc_id
  project_name        = var.project_name
  bastion_ingress_cidr = var.bastion_ingress_cidr
}

module "bastion" {
  source = "./modules/bastion"

  project_name      = var.project_name
  vpc_id            = module.networking.vpc_id
  subnet_id         = module.networking.public_subnet_ids[0]
  security_group_id = module.security.bastion_sg_id
  key_name          = var.key_name
  instance_type     = var.bastion_instance_type
  key_path          = "${path.root}/keys/k3s-key.pem"

  tags = {
    Environment = var.environment
  }
}

module "load_balancer" {
  source = "./modules/load_balancer"

  cluster_name          = var.cluster_name
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_sg_id
  domain_name           = var.domain_name
}

module "dns" {
  source       = "./modules/dns"

  domain_name     = var.domain_name
  alb_dns_name    = module.load_balancer.alb_dns_name
  alb_zone_id     = module.load_balancer.alb_zone_id
}

module "kubernetes" {
  source = "./modules/kubernetes"

  project_name             = var.project_name
  vpc_id                   = module.networking.vpc_id
  master_subnet_ids        = module.networking.private_subnet_ids
  worker_subnet_ids        = module.networking.private_subnet_ids
  master_security_group_id = module.security.k8s_masters_sg_id
  worker_security_group_id = module.security.k8s_workers_sg_id
  k8s_api_target_group_arn     = module.load_balancer.k8s_api_target_group_arn
  k8s_nodeport_target_group_arn = module.load_balancer.k8s_nodeport_target_group_arn
  key_name                 = var.key_name
  master_instance_type     = var.master_instance_type
  worker_instance_type     = var.worker_instance_type
  master_count             = var.master_count
  min_worker_count         = var.min_worker_count
  max_worker_count         = var.max_worker_count
  desired_worker_count     = var.desired_worker_count
  nlb_dns_name             = module.load_balancer.nlb_dns_name
  key_path                 = "${path.root}/keys/k3s-key.pem"
  bastion_public_ip        = module.bastion.bastion_public_ip
}