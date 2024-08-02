# --- root/outputs.tf ---

output "alb_dns" {
  value = module.alb.alb_dns_name
}

output "instances" {
  value     = { for i in module.compute.instance : i.tags.Name => "${i.public_ip}:${module.compute.instance_port}"}
  sensitive = true
}