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