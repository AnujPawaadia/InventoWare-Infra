resource "aws_launch_template" "blue" {
  name_prefix   = "${var.project}-blue-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = base64encode(data.template_file.user_data_blue.rendered)

  iam_instance_profile {
    name = var.instance_profile
  }

  vpc_security_group_ids = [var.instance_sg_id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project}-blue"
    }
  }
}

resource "aws_launch_template" "green" {
  name_prefix   = "${var.project}-green-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = base64encode(data.template_file.user_data_green.rendered)

  iam_instance_profile {
    name = var.instance_profile
  }

  vpc_security_group_ids = [var.instance_sg_id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project}-green"
    }
  }
}

resource "aws_autoscaling_group" "blue_asg" {
  name                = "${var.project}-blue-asg"
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = var.private_subnet_ids


  launch_template {
    id      = aws_launch_template.blue.id
    version = "$Latest"
  }

  target_group_arns = [var.blue_tg_arn]

  tag {
    key                 = "Name"
    value               = "${var.project}-blue"
    propagate_at_launch = true
  }
}


resource "aws_autoscaling_group" "green_asg" {
  name                = "${var.project}-green-asg"
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = var.private_subnet_ids


  launch_template {
    id      = aws_launch_template.green.id
    version = "$Latest"
  }

  target_group_arns = [var.green_tg_arn]

  tag {
    key                 = "Name"
    value               = "${var.project}-green"
    propagate_at_launch = true
  }
}
