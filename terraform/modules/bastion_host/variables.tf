variable "project" {
  description = "Project name"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for bastion EC2 (Ubuntu preferred)"
  type        = string
}

variable "instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "public_subnet_id" {
  description = "Public subnet to launch bastion"
  type        = string
}

variable "key_name" {
  description = "Name of the key pair"
  type        = string
}

variable "bastion_sg_id" {
  description = "Security Group ID to attach to the bastion"
  type        = string
}
