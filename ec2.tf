# EC2 Instance with Nginx
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = "lb"

  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = file("${path.module}/scripts/user_data.sh")

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
