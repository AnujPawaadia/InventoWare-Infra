resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "/${var.project}/app"
  retention_in_days = 14

  tags = {
    Name    = "${var.project}-app-logs"
    Project = var.project
  }
}

resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  name           = "${var.project}-5xx-filter"
  log_group_name = aws_cloudwatch_log_group.app_log_group.name
  pattern        = "[timestamp=*Z, request_id=\"*-*\", status_code=5*, ...]"

  metric_transformation {
    name      = "count_5xx_errors" # ✅ Renamed to start with letter
    namespace = "${var.project}/metrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "alarm_5xx" {
  alarm_name          = "${var.project}-high-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = aws_cloudwatch_log_metric_filter.error_filter.metric_transformation[0].name
  namespace           = "${var.project}/metrics"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  alarm_description = "Triggered if 5xx errors exceed threshold"
  actions_enabled   = false
}
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric",
        x      = 0,
        y      = 0,
        width  = 12,
        height = 6,
        properties = {
          view   = "timeSeries",
          title  = "CPU Utilization (Blue ASG)",
          region = var.aws_region,
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "${var.project}-blue-asg"]
          ],
          period = 60,
          stat   = "Average"
        }
      },
      {
        type   = "metric",
        x      = 12,
        y      = 0,
        width  = 12,
        height = 6,
        properties = {
          view   = "timeSeries",
          title  = "Network In/Out (Blue ASG)",
          region = var.aws_region,
          metrics = [
            ["AWS/EC2", "NetworkIn", "AutoScalingGroupName", "${var.project}-blue-asg"],
            [".", "NetworkOut", ".", "."]
          ],
          period = 60,
          stat   = "Sum"
        }
      },
      {
        type   = "metric",
        x      = 0,
        y      = 6,
        width  = 12,
        height = 6,
        properties = {
          view   = "timeSeries",
          title  = "Memory Usage (Blue ASG)",
          region = var.aws_region,
          metrics = [
            ["CWAgent", "mem_used_percent", "AutoScalingGroupName", "${var.project}-blue-asg"]
          ],
          period = 60,
          stat   = "Average"
        }
      },
      {
        type   = "metric",
        x      = 12,
        y      = 6,
        width  = 12,
        height = 6,
        properties = {
          view   = "timeSeries",
          title  = "5xx Errors (App Logs)",
          region = var.aws_region,
          metrics = [
            ["${var.project}/metrics", "count_5xx_errors"]
          ],
          period = 60,
          stat   = "Sum"
        }
      }
    ]
  })
}
