variable "aws_region" {
  default = "us-east-1"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI"
  default     = "ami-0c2b8ca1dad447f8a" # Replace with your region's AMI
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "Name of the AWS key pair"
}

variable "private_key_path" {
  description = "Path to your PEM file"
}

variable "docker_image_blue" {
  default = "yourdockerhub/image:blue"
}

variable "docker_image_green" {
  default = "yourdockerhub/image:green"
}
