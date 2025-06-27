output "load_balancer_dns" {
  description = "Public DNS of the Load Balancer"
  value       = aws_lb.app_lb.dns_name
}

output "monitoring_public_ip" {
  description = "Public IP of the monitoring instance"
  value       = aws_instance.monitoring_node.public_ip
}
