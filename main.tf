# --- root/main.tf ---


module "networking" {
  source           = "./networking"
  aws_cidr         = local.vpc_cidr
  security_groups  = local.security_groups
  public_sn_count  = 2
  private_sn_count = 3
  max_subnets      = 20
  access_ip        = var.access_ip
  public_cidrs     = [for i in range(1, 5, 1) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_cidrs    = [for i in range(6, 15, 1) : cidrsubnet(local.vpc_cidr, 8, i)]
  db_subnet_group  = true
}

module "database" {
  source                 = "./database"
  db_storage             = 10
  db_engine_version      = "5.7.44"
  db_instance_class      = "db.t3.micro"
  dbname                 = var.dbname
  dbuser                 = var.dbuser
  dbpassword             = var.dbpass
  db_identifier          = "K3-db"
  skip_db_snapshot       = true
  db_subnet_group_name   = module.networking.db_subnet_group_name[0]
  vpc_security_group_ids = module.networking.db_security_group
}

module "alb" {
  source                  = "./ALB"
  public_subnets          = module.networking.public_subnets
  public_sg               = module.networking.public_sg
  tg_port                 = 8000
  tg_protocol             = "HTTP"
  vpc_id                  = module.networking.vpc_id
  alb_healthy_threshold   = 2
  alb_unhealthy_threshold = 2
  alb_timeout             = 3
  alb_interval            = 30
  listener_port           = 8000
  listener_protocol       = "HTTP"
}

module "compute" {
  source          = "./compute"
  instance_count  = 2
  instance_type   = "t3.micro"
  public_sg       = module.networking.public_sg
  public_subnets  = module.networking.public_subnets
  vol_size        = 10
  key_name        = "k3key"
  public_key_path = "/home/ubuntu/.ssh/k3key.pub"
  user_data_path  = "${path.root}/userdata.tpl"
  dbname          = var.dbname
  dbuser          = var.dbuser
  dbpassword      = var.dbpass
  db_endpoint     = module.database.db_endpoint
  tg_arn          = module.alb.alb_tg
  tg_port         = 8000
}