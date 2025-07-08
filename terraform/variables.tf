variable "project" {
  type    = string
  default = "invento"
}

variable "bastion_allowed_cidr" {
  type        = string
  description = "Your IP address/CIDR for SSH access to bastion"
  default     = "0.0.0.0/0" # ⚠️ CHANGE this in production
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "key_name" {
  description = "Key pair for EC2 SSH access"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2"
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  description = "Port your application listens on"
  type        = number
  default     = 5000
}


variable "azs" {
  description = "List of Availability Zones"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"] # Adjust for your region
}

variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
}
