variable "project" {
  description = "Project name for tagging and naming resources"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "SSH key name for EC2"
  type        = string
}

variable "instance_profile" {
  description = "IAM instance profile name for EC2"
  type        = string
}

variable "instance_sg_id" {
  description = "Security group ID to attach to EC2 instances"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ASG"
  type        = list(string)
}

variable "blue_tg_arn" {
  description = "ARN of the target group for the blue environment"
  type        = string
}

variable "green_tg_arn" {
  description = "ARN of the target group for the green environment"
  type        = string
}

variable "azs" {
  description = "List of Availability Zones"
  type        = list(string)
}
