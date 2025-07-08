variable "project" {
  description = "Project name for tagging"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for Target Groups"
  type        = string
}

variable "app_port" {
  description = "Port on which app listens (e.g., 5000)"
  type        = number
}


