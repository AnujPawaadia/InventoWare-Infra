variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "bastion_allowed_cidr" {
  description = "CIDR block allowed to SSH into bastion (your IP)"
  type        = string
}
