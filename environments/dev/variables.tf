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
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "enable_nat_gateway" {
  type    = bool
  default = false
}

variable "allowed_ssh_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
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
  default = false
}

variable "s3_bucket_arns" {
  type    = list(string)
  default = []
}

variable "key_name" {
  type    = string
  default = "nikko-dev-key"
}

variable "create_bastion" {
  type    = bool
  default = true
}

variable "bastion_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "create_web_servers" {
  type    = bool
  default = true
}

variable "web_instance_count" {
  type    = number
  default = 1
}

variable "web_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "web_user_data" {
  type    = string
  default = ""
}

variable "create_app_servers" {
  type    = bool
  default = false
}

variable "app_instance_count" {
  type    = number
  default = 1
}

variable "app_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "app_user_data" {
  type    = string
  default = ""
}

variable "create_db_servers" {
  type    = bool
  default = false
}
