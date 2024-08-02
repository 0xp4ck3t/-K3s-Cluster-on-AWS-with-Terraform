# --- networking/outputs.tf ---

output "vpc_id" {
  value = aws_vpc.TF_VPC.id
}
output "db_subnet_group_name" {
  value = aws_db_subnet_group.TF_RDS_SG.*.name
}
output "db_security_group" {
  value = [aws_security_group.TF_SG["rds"].id]
}

output "public_sg" {
  value = aws_security_group.TF_SG["public"].id
}
output "public_subnets" {
  value = aws_subnet.TF_public_subnet.*.id
}