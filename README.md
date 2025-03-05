# AWS ALB with Nginx Web Server Infrastructure

This Terraform project deploys a web infrastructure on AWS, consisting of an Application Load Balancer (ALB) and an EC2 instance running Nginx.

## Architecture

- Application Load Balancer (ALB)
- EC2 instance with Nginx web server
- Security Groups for ALB and EC2
- Target Group for health checks
- VPC using default configuration

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (>= 1.0)
- AWS Account and [AWS CLI](https://aws.amazon.com/cli/) configured
- AWS IAM credentials with appropriate permissions

## Directory Structure

```
.
├── providers.tf    # AWS provider configuration
├── variables.tf    # Variable definitions
├── data.tf        # Data sources
├── security.tf    # Security group configurations
├── alb.tf         # Load balancer resources
├── ec2.tf         # EC2 instance configuration
├── outputs.tf     # Output definitions
├── scripts/
│   └── user_data.sh  # EC2 instance setup script
└── terraform.tfvars  # Variable values (not in git)
```

## Usage

1. Clone the repository:

```bash
git clone https://github.com/your-username/terraform-aws-alb-nginx.git
cd terraform-aws-alb-nginx
```

2. Create `terraform.tfvars` file with your values:

```hcll
instance_type    = "t2.micro"
aws_region       = "us-east-1"
```

3. Initialize Terraform:

```bash
terraform init
```

4. Plan the deployment:

```bash
terraform plan -out=tfplan
```

5. Apply the changes:

```bash
terraform apply tfplan
```

## Accessing the Web Server

After successful deployment, you can access:

- Web server through ALB DNS (output: `alb_dns_name`)
- EC2 instance directly (output: `ec2_public_ip`)

## SSH Access

To connect to the EC2 instance:

```bash
ssh -i path/to/your-key.pem ec2-user@<ec2_public_ip>
```

## Clean Up

To destroy all resources:

```bash
terraform destroy
```

## Security Notes

- The EC2 security group allows SSH access from any IP by default
- For production use, restrict SSH access to specific IP ranges
- Consider adding HTTPS support with ACM certificates
- Review and adjust security group rules as needed

## Outputs

| Name          | Description                   |
| ------------- | ----------------------------- |
| alb_dns_name  | DNS name of the load balancer |
| ec2_public_ip | Public IP of the EC2 instance |

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- AWS Documentation
- Terraform Documentation
- HashiCorp Learn Guides
