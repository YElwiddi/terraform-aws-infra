output "instance_ids" {
  value = aws_instance.main[*].id
}

output "instance_arns" {
  value = aws_instance.main[*].arn
}

output "private_ips" {
  value = aws_instance.main[*].private_ip
}

output "public_ips" {
  value = aws_instance.main[*].public_ip
}

output "elastic_ips" {
  value = aws_eip.main[*].public_ip
}

output "private_dns" {
  value = aws_instance.main[*].private_dns
}

output "public_dns" {
  value = aws_instance.main[*].public_dns
}

output "key_pair_name" {
  value = var.public_key != "" ? aws_key_pair.main[0].key_name : var.key_name
}
