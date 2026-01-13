variable "environment" {
  type = string
}

variable "instance_name" {
  type    = string
  default = "server"
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami_id" {
  type    = string
  default = ""
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "instance_profile_name" {
  type    = string
  default = ""
}

variable "key_name" {
  type    = string
  default = ""
}

variable "public_key" {
  type    = string
  default = ""
}

variable "root_volume_size" {
  type    = number
  default = 20
}

variable "root_volume_type" {
  type    = string
  default = "gp3"
}

variable "encrypt_root_volume" {
  type    = bool
  default = true
}

variable "additional_ebs_volumes" {
  type = list(object({
    device_name           = string
    volume_size           = number
    volume_type           = string
    encrypted             = bool
    delete_on_termination = bool
  }))
  default = []
}

variable "user_data" {
  type    = string
  default = ""
}

variable "enable_detailed_monitoring" {
  type    = bool
  default = false
}

variable "associate_elastic_ip" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
