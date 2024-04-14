resource "aws_lb" "web_alb" {
  name               = "web-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_alb_sg["web_alb"].id]
  subnets            = aws_subnet.web_tier_subnet.*.id
  idle_timeout       = 400

  tags = {
    Name = "Web Tier ALB"
  }
}

resource "aws_lb_target_group" "web_tier_tg" {
  name     = "web-tier-tg"
  port     = var.web_alb_tg_port
  protocol = var.web_alb_protocol
  vpc_id   = aws_vpc.three_tier.id
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
  health_check {
    healthy_threshold   = var.web_healthy_threshold   #2
    unhealthy_threshold = var.web_unhealthy_threshold #2
    timeout             = var.web_alb_timeout         #3
    interval            = var.web_alb_interval        #30
  }

}

resource "aws_lb_listener" "web_tier_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = var.web_listener_port     #80
  protocol          = var.web_listener_protocol #HTTP

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tier_tg.arn 
  }
}

resource "aws_lb" "app_alb" {
  name               = "app-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_alb_sg["app_alb"].id]
  subnets            = aws_subnet.app_tier_subnet.*.id
  idle_timeout       = 400

  tags = {
    Name = "App Tier ALB"
  }
}

resource "aws_lb_target_group" "app_tier_tg" {
  name     = "app-tier-tg"
  port     = var.app_alb_tg_port
  protocol = var.app_alb_protocol
  vpc_id   = aws_vpc.three_tier.id
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
  health_check {
    healthy_threshold   = var.app_healthy_threshold   #2
    unhealthy_threshold = var.app_unhealthy_threshold #2
    timeout             = var.app_alb_timeout         #3
    interval            = var.app_alb_interval        #30
  }
}

resource "aws_lb_listener" "app_tier_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = var.app_listener_port     #80
  protocol          = var.app_listener_protocol #HTTP

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tier_tg.arn
  }
}