# --- alb/outputs.tf ---

output "alb_tg" {
  value = aws_alb_target_group.K3-TG.arn
}
output "alb_dns_name" {
  value = aws_alb.K3_ALB.dns_name
}