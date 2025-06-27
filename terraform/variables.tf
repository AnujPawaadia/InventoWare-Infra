# variables.tf

variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "eu-north-1"
}

variable "key_name" {
  description = "SSH key pair name for EC2 instances"
  type        = string
}

variable "deployment_color" {
  description = "Which deployment should be active on the load balancer"
  type        = string
  default     = "blue"
}
