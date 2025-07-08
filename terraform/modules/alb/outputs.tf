output "alb_arn" {
  value = aws_lb.app_alb.arn
}

output "blue_target_group_arn" {
  value = aws_lb_target_group.blue_tg.arn
}

output "green_target_group_arn" {
  value = aws_lb_target_group.green_tg.arn
}
