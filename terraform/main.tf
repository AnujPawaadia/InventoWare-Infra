# main.tf — NLB with EIP and forwarding to ALB

provider "aws" {
  region = var.region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# --- Security Group ---
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow SSH and app access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Launch Template ---
resource "aws_launch_template" "app_template" {
  name_prefix   = "inventoware-template-"
  image_id      = "ami-0becc523130ac9d5d"
  instance_type = "t3.medium"
  key_name      = var.key_name

  user_data = base64encode(<<EOF
#!/bin/bash
sudo apt-get update -y
sudo apt-get install docker.io -y
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu
EOF
  )

  vpc_security_group_ids = [aws_security_group.app_sg.id]
}

# --- Target Groups ---
resource "aws_lb_target_group" "blue_tg" {
  name        = "inventoware-blue-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    path = "/"
    port = "5000"
  }
}

resource "aws_lb_target_group" "green_tg" {
  name        = "inventoware-green-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    path = "/"
    port = "5000"
  }
}

# --- Application Load Balancer (ALB) ---
resource "aws_lb" "app_alb" {
  name               = "inventoware-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = data.aws_subnets.public.ids
  security_groups    = [aws_security_group.app_sg.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.deployment_color == "blue" ? aws_lb_target_group.blue_tg.arn : aws_lb_target_group.green_tg.arn
  }
}

# --- Network Load Balancer (NLB) with EIP ---
resource "aws_eip" "nlb_eip" {
  count  = length(data.aws_subnets.public.ids)
  domain = "vpc"
}

resource "aws_lb" "nlb" {
  name                             = "inventoware-nlb"
  internal                         = false
  load_balancer_type               = "network"
  subnets                          = data.aws_subnets.public.ids
  enable_cross_zone_load_balancing = true

  dynamic "subnet_mapping" {
    for_each = data.aws_subnets.public.ids
    content {
      subnet_id     = subnet_mapping.value
      allocation_id = aws_eip.nlb_eip[subnet_mapping.key].id
    }
  }
}

# --- NLB Listener (TCP Forwarding to ALB) ---
resource "aws_lb_listener" "nlb_tcp_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue_tg.arn
  }
}

# --- Auto Scaling Groups ---
resource "aws_autoscaling_group" "blue_asg" {
  name                = "inventoware-blue-asg"
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.blue_tg.arn]
  vpc_zone_identifier = data.aws_subnets.public.ids

  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "InventoWare-Deployment-Blue"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "green_asg" {
  name                = "inventoware-green-asg"
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.green_tg.arn]
  vpc_zone_identifier = data.aws_subnets.public.ids

  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "InventoWare-Deployment-Green"
    propagate_at_launch = true
  }
}

# --- Monitoring Node ---
resource "aws_instance" "monitoring_node" {
  ami                    = "ami-0becc523130ac9d5d"
  instance_type          = "t3.medium"
  key_name               = var.key_name
  subnet_id              = data.aws_subnets.public.ids[0]
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
