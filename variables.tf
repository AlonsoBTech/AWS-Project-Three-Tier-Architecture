variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "ssh_access" {
    type = string
}

variable "web_alb_tg_port" {
  type = number
}

variable "web_alb_protocol" {
  type = string
}

variable "web_healthy_threshold" {
  type = number
}

variable "web_unhealthy_threshold" {
  type = number
}

variable "web_alb_timeout" {
  type = number
}

variable "web_alb_interval" {
  type = number
}

variable "web_listener_port" {
  type = number
}

variable "web_listener_protocol" {
  type = string
}

variable "app_alb_tg_port" {
  type = number
}

variable "app_alb_protocol" {
  type = string
}

variable "app_healthy_threshold" {
  type = number
}

variable "app_unhealthy_threshold" {
  type = number
}

variable "app_alb_timeout" {
  type = number
}

variable "app_alb_interval" {
  type = number
}

variable "app_listener_port" {
  type = number
}

variable "app_listener_protocol" {
  type = string
}

variable "webkey_name" {
  type = string
}

variable "webkey_public_path" {
  type = string
}

variable "web_instance_type" {
  type = string
}

variable "appkey_name" {
  type = string
}

variable "appkey_public_path" {
  type = string
}

variable "app_instance_type" {
  type = string
}

variable "db_identifier" {
  type = string
}

variable "db_storage" {
  type = number
}

variable "dbname" {
  type = string
}

variable "db_engine" {
  type = string
}

variable "db_engine_version" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_multi_az" {
  type = bool
}

variable "dbuser" {
  type = string
}

variable "dbpass" {
  type = string
}

variable "db_parameter_group_name" {
  type = string
}

variable "db_skip_snapshot" {
  type = bool
}