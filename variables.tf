variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Common local variables
locals {
  tcp_protocol = "tcp"
  all_ports    = "-1"
  anywhere     = "0.0.0.0/0"
  ssh_port     = 22
}
