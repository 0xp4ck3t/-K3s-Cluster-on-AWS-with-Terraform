# --- networking/variables.tf ---


variable "aws_cidr" {
  type = string
}
variable "public_cidrs" {
  type = list(string)
}

variable "private_cidrs" {
  type = list(string)
}

variable "public_sn_count" {
  type = number
}

variable "private_sn_count" {
  type = number
}

variable "max_subnets" {
  type = number
}

variable "access_ip" {}

variable "security_groups" {}

variable "db_subnet_group" {
  type = bool
}
