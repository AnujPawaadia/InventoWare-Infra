# --- Network Load Balancer (NLB) with EIP ---
resource "aws_eip" "nlb_eip" {
  count  = length(data.aws_subnets.public.ids)
  domain = "vpc"
}

resource "aws_lb" "nlb" {
  name                             = "inventoware-nlb"
  internal                         = false
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true

  # ❗ Only use `subnet_mapping` OR `subnets`, not both. Here we use `subnet_mapping` with EIPs.
  dynamic "subnet_mapping" {
    for_each = data.aws_subnets.public.ids
    content {
      subnet_id     = subnet_mapping.value
      allocation_id = aws_eip.nlb_eip[subnet_mapping.key].id
    }
  }
}

# --- Target Groups ---
resource "aws_lb_target_group" "blue_tg" {
  name        = "inventoware-blue-tg"
  port        = 5000
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    port     = "5000"
    protocol = "TCP"
  }
}

resource "aws_lb_target_group" "green_tg" {
  name        = "inventoware-green-tg"
  port        = 5000
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    port     = "5000"
    protocol = "TCP"
  }
}

# --- NLB Listener (TCP Forwarding to Blue/Green Target Group) ---
locals {
  selected_tg = var.deployment_color == "blue" ? aws_lb_target_group.blue_tg.arn : aws_lb_target_group.green_tg.arn
}

resource "aws_lb_listener" "nlb_tcp_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 5000
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = local.selected_tg
  }
}

# ✅ Removed ASGs, replaced with fixed EC2 instances

resource "aws_instance" "blue_instance" {
  ami                         = "ami-0becc523130ac9d5d"
  instance_type               = "t3.medium"
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnets.public.ids[0]
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "InventoWare-Deployment-Blue"
  }

  user_data = <<EOF
#!/bin/bash
sudo apt-get update -y
sudo apt-get install docker.io -y
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu
EOF
}

resource "aws_instance" "green_instance" {
  ami                         = "ami-0becc523130ac9d5d"
  instance_type               = "t3.medium"
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnets.public.ids[1]
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "InventoWare-Deployment-Green"
  }

  user_data = <<EOF
#!/bin/bash
sudo apt-get update -y
sudo apt-get install docker.io -y
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu
EOF
}

# --- Monitoring Node ---
resource "aws_instance" "monitoring_node" {
  ami                    = "ami-0becc523130ac9d5d"
  instance_type          = "t3.medium"
  key_name               = var.key_name
  subnet_id              = data.aws_subnets.public.ids[2]
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "InventoWare-Monitoring"
  }

  user_data = <<EOF
#!/bin/bash
sudo apt-get update -y
sudo apt-get install docker.io -y
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu
EOF
}

output "nlb_dns_name" {
  value = aws_lb.nlb.dns_name
}

output "blue_ip" {
  value = aws_instance.blue_instance.public_ip
}

output "green_ip" {
  value = aws_instance.green_instance.public_ip
}

output "monitoring_ip" {
  value = aws_instance.monitoring_node.public_ip
}
