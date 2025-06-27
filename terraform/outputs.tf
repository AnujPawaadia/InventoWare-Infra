# outputs.tf

output "monitoring_instance_public_ip" {
  description = "Public IP of the monitoring EC2 instance"
  value       = aws_instance.monitoring_node.public_ip
}

output "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer"
  value       = aws_lb.nlb.dns_name
}

output "nlb_eips" {
  description = "EIP addresses attached to the NLB"
  value = [
    for eip in aws_eip.nlb_eip : eip.public_ip
  ]
}

output "monitoring_node_ip" {
  description = "Public IP of the monitoring node"
  value       = aws_instance.monitoring_node.public_ip
}

