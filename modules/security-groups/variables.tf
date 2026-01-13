variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "create_bastion_sg" {
  type    = bool
  default = true
}

variable "create_web_sg" {
  type    = bool
  default = true
}

variable "create_app_sg" {
  type    = bool
  default = true
}

variable "create_db_sg" {
  type    = bool
  default = true
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

variable "tags" {
  type    = map(string)
  default = {}
}
