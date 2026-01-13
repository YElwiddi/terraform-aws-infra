variable "environment" {
  type = string
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
  default = ["arn:aws:s3:::*"]
}

variable "custom_policy_json" {
  type    = string
  default = ""
}

variable "create_app_role" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
