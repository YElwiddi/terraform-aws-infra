output "ec2_role_arn" {
  value = aws_iam_role.ec2_role.arn
}

output "ec2_role_name" {
  value = aws_iam_role.ec2_role.name
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}

output "ec2_instance_profile_arn" {
  value = aws_iam_instance_profile.ec2_profile.arn
}

output "app_role_arn" {
  value = var.create_app_role ? aws_iam_role.app_role[0].arn : null
}

output "app_instance_profile_name" {
  value = var.create_app_role ? aws_iam_instance_profile.app_profile[0].name : null
}
