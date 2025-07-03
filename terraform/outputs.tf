output "blue_instance_eip" {
  description = "Elastic IP of the Blue instance"
  value       = aws_eip.blue_eip.public_ip
}

output "green_instance_eip" {
  description = "Elastic IP of the Green instance"
  value       = aws_eip.green_eip.public_ip
}

output "monitor_instance_eip" {
  description = "Elastic IP of the Monitor instance"
  value       = aws_eip.monitor_eip.public_ip
}
