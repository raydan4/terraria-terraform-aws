# AWS Options
variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "terraria_world_s3_bucket" {
  type = string
}

# Terraria Server Options
variable "terraria_root_dir" {
  type = string
  default = "/opt/terraria"
}

variable "terraria_version" {
  type = number
  default = 1449
}

variable "authorized_key" {
  type = string
}

# Terraria Config Options
variable "terraria_config_autocreate" {
  type = number
  default = 1
}

variable "terraria_config_seed" {
  type = string
  default = "AwesomeSeed"
}

variable "terraria_config_world_name" {
  type = string
  default = "Home"
}

variable "terraria_config_difficulty" {
  type = number
  default = 0
}

variable "terraria_config_maxplayers" {
  type = number
  default = 8
}

variable "terraria_config_port" {
  type = number
  default = 7777
}

variable "terraria_config_password" {
  type = string
}

variable "terraria_config_anticheat" {
  type = number
  default = 1
}

variable "terraria_config_language" {
  type = string
  default = "en-US"
}
