variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "nikko-infra"
}

variable "vpc_cidr" {
  type    = string
  default = "10.2.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.2.10.0/24", "10.2.20.0/24", "10.2.30.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "allowed_ssh_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/8"]
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "enable_ssm" {
  type    = bool
  default = true
}

variable "enable_cloudwatch" {
  type    = bool
  default = true
}

variable "enable_s3_read" {
  type    = bool
  default = true
}

variable "s3_bucket_arns" {
  type    = list(string)
  default = ["arn:aws:s3:::nikko-app-assets-prod/*"]
}

variable "key_name" {
  type    = string
  default = "nikko-prod-key"
}

variable "create_bastion" {
  type    = bool
  default = true
}

variable "bastion_instance_type" {
  type    = string
  default = "t3.small"
}

variable "create_web_servers" {
  type    = bool
  default = true
}

variable "web_instance_count" {
  type    = number
  default = 3
}

variable "web_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "web_user_data" {
  type    = string
  default = ""
}

variable "create_app_servers" {
  type    = bool
  default = true
}

variable "app_instance_count" {
  type    = number
  default = 3
}

variable "app_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "app_user_data" {
  type    = string
  default = ""
}

variable "create_db_servers" {
  type    = bool
  default = true
}
