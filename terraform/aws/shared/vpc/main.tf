locals {
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    Terraform = "true"
    Workspace = "s3://457661787930-terraform-backend/terraform/aws/shared/vpc/${terraform.workspace}"
  }
  private_sg_ingress_cidr_blocks = {
    "${var.vpc_name}" = [
      module.vpc.vpc_cidr_block
    ]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs              = local.azs
  private_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets   = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]
  intra_subnets    = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 52)]
  #database_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 52)]

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  #   enable_flow_log                      = true
  #   create_flow_log_cloudwatch_iam_role  = true
  #   create_flow_log_cloudwatch_log_group = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = var.cluster_name
  }

  tags = local.tags
}

# Default security groups
module "default_public_sg" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "~> 5.0"

  name                = "${var.vpc_name}_default_public_sg"
  description         = "Default security group for public subnet"
  vpc_id              = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp","http-80-tcp"]
  egress_rules        = ["all-all"]

  tags                = local.tags
}

module "default_private_sg" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "~> 5.0"

  name                = "${var.vpc_name}_default_private_sg"
  description         = "Default security group for private subnet"
  vpc_id              = module.vpc.vpc_id

  ingress_cidr_blocks = toset(lookup(local.private_sg_ingress_cidr_blocks, var.vpc_name, [module.vpc.vpc_cidr_block]))
  ingress_rules       = ["all-all"]
  egress_rules        = ["all-all"]

  tags                = local.tags
}

module "default_database_sg" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "~> 5.0"
  
  name                = "${var.vpc_name}_default_database_sg"
  description         = "Default security group for database subnet"
  vpc_id              = module.vpc.vpc_id

  ingress_cidr_blocks = toset(lookup(local.private_sg_ingress_cidr_blocks, var.vpc_name, [module.vpc.vpc_cidr_block]))
  ingress_rules       = ["postgresql-tcp","mysql-tcp","memcached-tcp","redis-tcp","mongodb-27017-tcp"]
  egress_rules        = ["all-all"]

  tags                = local.tags
}
