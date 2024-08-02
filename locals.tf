locals {
  vpc_cidr = "10.10.0.0/16"
}

locals {
  security_groups = {
    public = {
      name        = "public_SG"
      description = "SG for Public Access"
      ingress = {
        ssh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
        nginx = {
          from        = 8000
          to          = 8000
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
      }
    }
    rds = {
      name        = "RDS_SG"
      description = "SG for DB Access"
      ingress = {
        mysql = {
          from        = 3306
          to          = 3306
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
      }
    }
  }
}