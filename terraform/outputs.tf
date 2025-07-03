output "blue_instance_ip" {
  description = "Public IP address of the Blue deployment instance"
  value       = aws_eip.blue_eip.public_ip
}

output "green_instance_ip" {
  description = "Public IP address of the Green deployment instance"
  value       = aws_eip.green_eip.public_ip
}

output "monitoring_instance_ip" {
  description = "Public IP address of the Monitoring instance"
  value       = aws_eip.monitor_eip.public_ip
}
