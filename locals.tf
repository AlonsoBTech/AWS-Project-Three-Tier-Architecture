locals {
  web_subnet_cidr = [for i in range(2, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
}

locals {
  app_subnet_cidr = [for i in range(1, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
}

locals {
  data_subnet_cidr = [for i in range(5, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
}

locals {
  azs = data.aws_availability_zones.available.names
}

locals {
  web_alb_sg = {
    web_alb = {
      name        = "web_alb_sg"
      description = "Web Tier ALB Security Group"
      ingress = {
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        https = {
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
  web_asg_sg = {
    web_asg = {
      name        = "web_asg_sg"
      description = "Web Tier ASG Security Group"
      ingress = {
        http = {
          from            = 80
          to              = 80
          protocol        = "tcp"
          security_groups = [aws_security_group.web_alb_sg["web_alb"].id]
        }
        https = {
          from            = 443
          to              = 443
          protocol        = "tcp"
          security_groups = [aws_security_group.web_alb_sg["web_alb"].id]
        }
        ssh = {
          from            = 22
          to              = 22
          protocol        = "tcp"
          security_groups = [aws_security_group.ssh_sg.id]
        }
      }
    }
  }
  app_alb_sg = {
    app_alb = {
      name        = "app_alb_sg"
      description = "App Tier ALB Security Group"
      ingress = {
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        https = {
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
  app_asg_sg = {
    app_asg = {
      name        = "app_asg_sg"
      description = "App Tier ASG Security Group"
      ingress = {
        http = {
          from            = 80
          to              = 80
          protocol        = "tcp"
          security_groups = [aws_security_group.app_alb_sg["app_alb"].id]
        }
        https = {
          from            = 443
          to              = 443
          protocol        = "tcp"
          security_groups = [aws_security_group.app_alb_sg["app_alb"].id]
        }
        ssh = {
          from            = 22
          to              = 22
          protocol        = "tcp"
          security_groups = [aws_security_group.ssh_sg.id]
        }
      }
    }
  }
}
