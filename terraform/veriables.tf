variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "nexvion"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed for SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_http_cidr" {
  description = "CIDR allowed for HTTP"
  type        = string
  default     = "0.0.0.0/0"
}
