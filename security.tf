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
