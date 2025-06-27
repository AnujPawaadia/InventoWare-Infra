
variable "region" {
  default = "eu-north-1"
}

variable "key_name" {
  description = "Name of the AWS EC2 Key Pair"
  default     = "jenkins_invento" 
}

variable "deployment_color" {
  description = "Which target group to route traffic to: blue or green"
  default     = "blue"
}
