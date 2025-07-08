resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_lb" "app_alb" {
  name               = "${var.project}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [var.alb_sg_id]

  tags = {
    Name = "${var.project}-alb"
  }
}

resource "aws_lb_target_group" "blue_tg" {
  name        = "${var.project}-tg-blue-${random_id.suffix.hex}"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "${var.project}-tg-blue"
  }
}

resource "aws_lb_target_group" "green_tg" {
  name        = "${var.project}-tg-green-${random_id.suffix.hex}"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "${var.project}-tg-green"
  }
}


