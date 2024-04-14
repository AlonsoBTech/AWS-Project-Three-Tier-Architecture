resource "aws_security_group" "ssh_sg" {
  name        = "ssh_sg"
  description = "SSH Security Group"
  vpc_id      = aws_vpc.three_tier.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_access]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSH Security Group"
  }
}

resource "aws_security_group" "web_alb_sg" {
  for_each    = local.web_alb_sg
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.three_tier.id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web ALB Security Group"
  }
}

resource "aws_security_group" "web_asg_sg" {
  for_each    = local.web_asg_sg
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.three_tier.id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port       = ingress.value.from
      to_port         = ingress.value.to
      protocol        = ingress.value.protocol
      security_groups = ingress.value.security_groups
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web ASG Security Group"
  }
}

resource "aws_security_group" "app_alb_sg" {
  for_each    = local.app_alb_sg
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.three_tier.id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "App ALB Security Group"
  }
}

resource "aws_security_group" "app_asg_sg" {
  for_each    = local.app_asg_sg
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.three_tier.id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port       = ingress.value.from
      to_port         = ingress.value.to
      protocol        = ingress.value.protocol
      security_groups = ingress.value.security_groups
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "App ASG Security Group"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Database Security Group"
  vpc_id      = aws_vpc.three_tier.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_asg_sg["app_asg"].id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Data Security Group"
  }
}
