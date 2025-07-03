variable "aws_region" {
  default = "us-east-1"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI"
  default     = "ami-0c2b8ca1dad447f8a" # Replace with your region-specific AMI
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "invento_jenkins"
}
