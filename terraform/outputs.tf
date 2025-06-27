# outputs.tf

output "app_alb_eip" {
  description = "Elastic IP address associated with the Application Load Balancer"
  value       = aws_eip.app_lb_eip.public_ip
}

output "load_balancer_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.app_lb.dns_name
}

output "monitoring_instance_public_ip" {
  description = "Public IP of the monitoring EC2 instance"
  value       = aws_instance.monitoring_node.public_ip
}
