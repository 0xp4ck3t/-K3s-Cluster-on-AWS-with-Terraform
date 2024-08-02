# --- compute/outputs.tf ---

output "instance_id" {
  value = aws_instance.k3_node.*.id
}

output "instance" {
  value     = aws_instance.k3_node[*]
  sensitive = true
}

output "instance_port" {
  value = aws_alb_target_group_attachment.k3-tg-at[0].port
}