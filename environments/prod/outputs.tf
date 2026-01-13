output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "bastion_public_ip" {
  value = var.create_bastion ? module.bastion[0].elastic_ips[0] : null
}

output "web_server_ips" {
  value = var.create_web_servers ? module.web_servers[0].public_ips : []
}

output "app_server_ips" {
  value = var.create_app_servers ? module.app_servers[0].private_ips : []
}

output "ec2_instance_profile" {
  value = module.iam.ec2_instance_profile_name
}
