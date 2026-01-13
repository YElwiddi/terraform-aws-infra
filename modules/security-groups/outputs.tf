output "bastion_sg_id" {
  value = var.create_bastion_sg ? aws_security_group.bastion[0].id : null
}

output "web_sg_id" {
  value = var.create_web_sg ? aws_security_group.web[0].id : null
}

output "app_sg_id" {
  value = var.create_app_sg ? aws_security_group.app[0].id : null
}

output "db_sg_id" {
  value = var.create_db_sg ? aws_security_group.db[0].id : null
}
