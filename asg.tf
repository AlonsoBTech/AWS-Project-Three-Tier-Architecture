### Creating Web Tier SSH Key
resource "aws_key_pair" "web_tier_key" {
  key_name   = var.webkey_name
  public_key = file(var.webkey_public_path)
}

### Creating Web Tier ASG EC2 Launch Template 
resource "aws_launch_template" "web_tier_launch_tpl" {
  name_prefix   = "web_tier_template"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.web_instance_type
  key_name = aws_key_pair.web_tier_key.id
  network_interfaces {
    device_index    = 0
    security_groups = [aws_security_group.web_asg_sg["web_asg"].id]
  }
  user_data = filebase64("${path.root}/web_userdata.sh")
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "WebServer"
    }
  }

  tags = {
    Name = "Web Tier Launch Template"
  }
}

### Creating Web Tier ASG
resource "aws_autoscaling_group" "web_tier_asg" {
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  health_check_type        = "EC2"
  target_group_arns   = [aws_lb_target_group.web_tier_tg.arn]
  vpc_zone_identifier = aws_subnet.web_tier_subnet.*.id

  launch_template {
    id      = aws_launch_template.web_tier_launch_tpl.id
    version = "$Latest"
  }
}

### Creating App Tier SSH Key
resource "aws_key_pair" "app_tier_key" {
  key_name   = var.appkey_name
  public_key = file(var.appkey_public_path)
}

### Creating App Tier ASG EC2 Launch Template 
resource "aws_launch_template" "app_tier_launch_tpl" {
  name_prefix   = "app_tier_template"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.app_instance_type
  key_name = aws_key_pair.app_tier_key.id
  network_interfaces {
    device_index    = 0
    security_groups = [aws_security_group.app_asg_sg["app_asg"].id]
  }
  user_data = filebase64("${path.root}/app_userdata.sh")
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "AppServer"
    }
  }

  tags = {
    Name = "App Tier Launch Template"
  }
}

### Creating App Tier ASG 
resource "aws_autoscaling_group" "app_tier_asg" {
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  health_check_type        = "EC2"
  target_group_arns   = [aws_lb_target_group.app_tier_tg.arn]
  vpc_zone_identifier = aws_subnet.app_tier_subnet.*.id

  launch_template {
    id      = aws_launch_template.app_tier_launch_tpl.id
    version = "$Latest"
  }
}
