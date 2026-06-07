data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs          = slice(data.aws_availability_zones.available.names, 0, 2)
  common_tags  = var.tags
  cluster_name = var.cluster_name
}

module "vpc" {
  source       = "./modules/vpc"
  cluster_name = local.cluster_name
  vpc_cidr     = var.vpc_cidr
  azs          = local.azs
  tags         = local.common_tags
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  tags            = local.common_tags
}

module "iam" {
  source            = "./modules/iam"
  cluster_name      = local.cluster_name
  assets_bucket_arn = module.serverless.assets_bucket_arn
  tags              = local.common_tags
}

module "data" {
  source              = "./modules/data"
  cluster_name        = local.cluster_name
  vpc_id              = module.vpc.vpc_id
  private_subnets     = module.vpc.private_subnets
  node_security_group = module.eks.node_security_group_id
  db_username         = var.db_username
  tags                = local.common_tags
}

module "serverless" {
  source     = "./modules/serverless"
  student_id = var.student_id
  tags       = local.common_tags
}
