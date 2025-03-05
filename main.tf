provider "aws" {
  region = "us-east-1"
}

# AMI Data Source
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# VPC Data Source
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "alb-security-group"
  description = "Security group for ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = local.tcp_protocol
    cidr_blocks = [local.anywhere]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = local.all_ports
    cidr_blocks = [local.anywhere]
  }

  tags = {
    Name = "alb-security-group"
  }
}

# Security Group for EC2
resource "aws_security_group" "ec2" {
  name        = "ec2-security-group"
  description = "Security group for EC2 instances"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = local.tcp_protocol
    security_groups = [aws_security_group.alb.id]
  }

  # Add SSH access
  ingress {
    from_port   = local.ssh_port
    to_port     = local.ssh_port
    protocol    = local.tcp_protocol
    cidr_blocks = [local.anywhere]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = local.all_ports
    cidr_blocks = [local.anywhere]
  }

  tags = {
    Name = "ec2-security-group"
  }
}

# Application Load Balancer
resource "aws_lb" "web_alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids

  tags = {
    Name = "web-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "web_tg" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

# ALB Listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# EC2 Instance with Nginx
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = "lb"

  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = <<-EOF
              #!/bin/bash

              # Update the package list
              amazon-linux-extras enable nginx1
              yum update -y

              # Install and start Nginx
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx

              # Verify Nginx is running
              systemctl status nginx
              EOF

  tags = {
    Name = "nginx-web-server"
  }

  # Add lifecycle rule to ensure proper destruction
  lifecycle {
    create_before_destroy = true
  }
}

# Attach EC2 instance to Target Group
resource "aws_lb_target_group_attachment" "web_tg_attachment" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_server.id
  port             = 80
}
