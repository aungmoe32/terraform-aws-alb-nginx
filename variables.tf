
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

locals {
  anywhere     = "0.0.0.0/0"
  all_ports    = "-1"
  ssh_port     = 22
  tcp_protocol = "tcp"
}
