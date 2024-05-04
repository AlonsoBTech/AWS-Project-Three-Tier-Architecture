# AWS Project Three Tier Architecture

## 📋 <a name="table">Table of Contents</a>

1. 🤖 [Introduction](#introduction)
2. ⚙️ [Prerequisites](#prerequisites)
3. 🔋 [What Is Being Created](#what-is-being-created)
4. 🤸 [Quick Guide](#quick-guide)

## <a name="introduction">🤖 Introduction</a>

Creating a highly available, scalable and secure AWS Three Tier Architecture for a web application. A three tier architecture offers
better scalability, flexibility and even maintainability and even cost efficiency. As each tier is sepearted we can allocate less intensive
resources to lower tiers and use more high performance resources where required, this allows for us to optimize how we manage our infrastructure cost.
Security is one of the key features here as well, with each tier isolated we can implement tailored security measures to help effectively mitigate
the risk for vulnerabilities.

![Architecture](https://github.com/AlonsoBTech/AWS-Project-Three-Tier-Architecture/assets/160416175/39c837b9-7886-43e7-b27e-eb06ec05e14e)



## <a name="prerequisites">⚙️ Prerequisites</a>

Make sure you have the following:

- AWS Account
- AWS IAM User
- Terraform Installed
- IDE of choice to write Terraform code

## <a name="what-is-being-created">🔋 What Is Being Created</a>

What we will be creating and using:

- VPC
- VPC Subnets
- VPC Internet Gateway
- VPC NAT Gateway
- VPC Route Table
- VPC Route Table Route
- VPC Route Table Associations
- EC2s
- Application Load Balancer
- Auto Scaling Group
- RDS Database
- ElastiCache
- Amazon S3
- AWS Shield DDoS Protection
- Amazon Cloudfront
- AWS WAF (Web Application Firewall)
- Route 53

  ## <a name="quick-guide">🤸 Quick Guide</a>

 **Create your Terraform providers.tf file**

 </details>

<details>
<summary><code>providers.tf</code></summary>

```bash
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

    backend "s3" {
    bucket = "three-tier-terraform-backend"
      key = "three-tier/terraform.tfstate"
      region = "ca-central-1"
    }
}

provider "aws" {
  region = var.aws_region
}
```
</details>

**Create your Terraform vpc.tf file**

</details>

<details>
<summary><code>vpc.tf</code></summary>

```bash
### Creating VPC
resource "aws_vpc" "three_tier" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Three Tier VPC"
  }
}

### Creating Web Tier Subnets
resource "aws_subnet" "web_tier_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.three_tier.id
  cidr_block              = local.web_subnet_cidr[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true


  tags = {
    Name = "Web Tier Public Subnet-${count.index + 1}"
  }
}

### Creating App Tier Subnets
resource "aws_subnet" "app_tier_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.three_tier.id
  cidr_block              = local.app_subnet_cidr[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false


  tags = {
    Name = "App Tier Private Subnet-${count.index + 1}"
  }
}

### Creating Data Tier Subnet
resource "aws_subnet" "data_tier_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.three_tier.id
  cidr_block              = local.data_subnet_cidr[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false


  tags = {
    Name = "Data Tier Private Subnet-${count.index + 1}"
  }
}

### Creating VPC Internet Gateway
resource "aws_internet_gateway" "three_tier_igw" {
  vpc_id = aws_vpc.three_tier.id

  tags = {
    Name = "Three Tier IGW"
  }
}

### Creating Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  count  = 2
  domain = "vpc"

  tags = {
    Name = "NAT EIP-${count.index + 1}"
  }
}

### Creating NAT Gateway for App Subnet Internet Access
resource "aws_nat_gateway" "three_tier_nat" {
  count         = 2
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.web_tier_subnet.*.id[count.index]

  depends_on = [aws_internet_gateway.three_tier_igw]

  tags = {
    Name = "Three Tier NAT-${count.index + 1}"
  }
}

### Creating Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.three_tier.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.three_tier_igw.id
  }

  tags = {
    Name = "Three Tier Public RT"
  }
}

### Creating Private Route Table
resource "aws_default_route_table" "default_rt" {
  default_route_table_id = aws_vpc.three_tier.default_route_table_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.three_tier_nat[0].id
  }

  tags = {
    Name = "Three Tier Default RT"
  }
}

### Creating Public Route Table Associations
resource "aws_route_table_association" "public_rt_asso_1" {
  count          = 2
  subnet_id      = aws_subnet.web_tier_subnet.*.id[count.index]
  route_table_id = aws_route_table.public_rt.id
}

### Creating Private Route Table Associations
resource "aws_route_table_association" "private_rt_asso_1" {
  count          = 2
  subnet_id      = aws_subnet.app_tier_subnet.*.id[count.index]
  route_table_id = aws_default_route_table.default_rt.id
}

### Creating Private Route Table Associations
resource "aws_route_table_association" "private_rt_asso_2" {
  count          = 2
  subnet_id      = aws_subnet.data_tier_subnet.*.id[count.index]
  route_table_id = aws_default_route_table.default_rt.id
}
```
</details>

**Create your Terraform security_group.tf file**

</details>

<details>
<summary><code>security_group.tf</code></summary>

```bash
### Creating Security Group for SSH
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

### Creating Security Group for Web Tier ALB
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

### Creating Security Group for Web Tier ASG
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

### Creating Security Group for App Tier ALB
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

### Creating Security Group for App Tier ASG
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

### Creating Security Group for Data Tier
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
```
</details>

**Create your Terraform locals.tf file**

</details>

<details>
<summary><code>locals.tf</code></summary>

```bash
### Defining Subnet CIDR Range for Web Tier Subnets to only have even numbers
locals {
  web_subnet_cidr = [for i in range(2, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
}

### Defining Subnet CIDR Range for App Tier Subnets to only have odd numbers
locals {
  app_subnet_cidr = [for i in range(1, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
}

### Defining Subnet CIDR Range for Data Tier Subnets to only have odd numbers
locals {
  data_subnet_cidr = [for i in range(5, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
}

### Defining Availability Zones to use
locals {
  azs = data.aws_availability_zones.available.names
}

### Defining Web & App Tier Security Groups Ingress Rules
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
```
</details>

**Create your Terraform data.tf file**

</details>

<details>
<summary><code>data.tf</code></summary>

```bash
### Defining Availability Zones to use
data "aws_availability_zones" "available" {}

### Defining EC2 AMI to use for Web & App Tier ASG
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}
```
</details>

**Create your Terraform asg.tf file**

</details>

<details>
<summary><code>asg.tf</code></summary>

```bash
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
  user_data = filebase64("web_userdata.sh")
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
  user_data = filebase64("app_userdata.sh")
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
```
</details>

**Create your web_userdata.sh file**

</details>

<details>
<summary><code>web_userdata.sh</code></summary>

```bash
#!/bin/bash
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
sudo apt-get update -y
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<h1>Welcome to my Web Application</h1>" | sudo tee /var/www/html/index.html
echo "<p>Instance ID: $INSTANCE_ID </p>" | sudo tee -a /var/www/html/index.html
echo "<p>Availability Zone: $AVAILABILITY_ZONE </p>" | sudo tee -a /var/www/html/index.html
```
</details>

**Create your app_userdata.sh file**

</details>

<details>
<summary><code>app_userdata.sh</code></summary>

```bash
#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y mysql-client-core-8.0
```
</details>

**Create your Terraform alb.tf file**

</details>

<details>
<summary><code>alb.tf</code></summary>

```bash
### Creating Web Tier ALB
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

### Creating Web Tier ALB Targer Group
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

### Creating Web Tier ALB Listener
resource "aws_lb_listener" "web_tier_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = var.web_listener_port     #80
  protocol          = var.web_listener_protocol #HTTP

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tier_tg.arn 
  }
}

### Creating App Tier ALB
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

### Creating App Tier ALB Targer Group
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

### Creating App Tier ALB Listener
resource "aws_lb_listener" "app_tier_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = var.app_listener_port     #80
  protocol          = var.app_listener_protocol #HTTP

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tier_tg.arn
  }
}
```
</details>

**Create your Terraform rds.tf file**

</details>

<details>
<summary><code>rds.tf</code></summary>

```bash
### Creating Database Subnet Group
resource "aws_db_subnet_group" "rds_db_sub_grp" {
  name       = "rds_db_sub_grp"
  subnet_ids = aws_subnet.data_tier_subnet.*.id

  tags = {
    Name = "Data Tier DB Subnet Group"
  }
}

### Creating RDS MYSQL Database
resource "aws_db_instance" "data_tier_db" {
  identifier             = var.db_identifier
  allocated_storage      = var.db_storage
  db_name                = var.dbname
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  multi_az               = var.db_multi_az
  db_subnet_group_name   = aws_db_subnet_group.rds_db_sub_grp.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  username               = var.dbuser
  password               = var.dbpass
  parameter_group_name   = var.db_parameter_group_name
  skip_final_snapshot    = var.db_skip_snapshot

  tags = {
    Name = "Data Tier DB"
  }
}
```
</details>

**Create your Terraform variables.tf file**

</details>

<details>
<summary><code>variables.tf</code></summary>

```bash
#### ALL VARIABLE VALUES ARE KEPT IN "TERRAFORM.TFVARS" ####

variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "ssh_access" {
    type = string
}

variable "web_alb_tg_port" {
  type = number
}

variable "web_alb_protocol" {
  type = string
}

variable "web_healthy_threshold" {
  type = number
}

variable "web_unhealthy_threshold" {
  type = number
}

variable "web_alb_timeout" {
  type = number
}

variable "web_alb_interval" {
  type = number
}

variable "web_listener_port" {
  type = number
}

variable "web_listener_protocol" {
  type = string
}

variable "app_alb_tg_port" {
  type = number
}

variable "app_alb_protocol" {
  type = string
}

variable "app_healthy_threshold" {
  type = number
}

variable "app_unhealthy_threshold" {
  type = number
}

variable "app_alb_timeout" {
  type = number
}

variable "app_alb_interval" {
  type = number
}

variable "app_listener_port" {
  type = number
}

variable "app_listener_protocol" {
  type = string
}

variable "webkey_name" {
  type = string
}

variable "webkey_public_path" {
  type = string
}

variable "web_instance_type" {
  type = string
}

variable "appkey_name" {
  type = string
}

variable "appkey_public_path" {
  type = string
}

variable "app_instance_type" {
  type = string
}

variable "db_identifier" {
  type = string
}

variable "db_storage" {
  type = number
}

variable "dbname" {
  type = string
}

variable "db_engine" {
  type = string
}

variable "db_engine_version" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_multi_az" {
  type = bool
}

variable "dbuser" {
  type = string
}

variable "dbpass" {
  type = string
}

variable "db_parameter_group_name" {
  type = string
}

variable "db_skip_snapshot" {
  type = bool
}
```
</details>

**Create Terraform terraform.tfvars to add your variables value and add this file to your .gitignore file.**

**Deploy your code to AWS with the following commands**

```bash
terraform init
terraform plan
terraform validate
terraform plan
terraform apply -auto-approve
```
**Check your AWS console to see your resoucres then run Terraform command to delete everything**

```bash
terraform destroy -auto-approve
```

## <a name="links">🔗 Links</a>

- [Terraform AWS Provider Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Project Blog Post](https://medium.com/@lonsobraithwaite1996/deploying-3-tier-architecture-to-aws-using-terraform-b34eb181787a)
