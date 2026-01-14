# Terraform AWS Infrastructure

Infrastructure-as-Code (IaC) repository for provisioning and managing AWS cloud infrastructure using Terraform. Supports multi-environment deployments (dev, staging, production) with reusable modules.

## Architecture

```
                        ┌─────────────────────────────────────────┐
                        │              VPC (10.0.0.0/16)          │
                        │                                         │
    Internet ──────────►│  ┌─────────────┐    ┌─────────────┐    │
                        │  │   Public    │    │   Public    │    │
         │              │  │  Subnet 1   │    │  Subnet 2   │    │
         │              │  │  (AZ-1a)    │    │  (AZ-1b)    │    │
         │              │  │             │    │             │    │
         │              │  │  Bastion    │    │    Web      │    │
         │              │  │   Host      │    │  Servers    │    │
         │              │  └──────┬──────┘    └──────┬──────┘    │
         │              │         │                  │            │
         │              │         ▼                  ▼            │
         │              │  ┌─────────────┐    ┌─────────────┐    │
         │              │  │   Private   │    │   Private   │    │
         │              │  │  Subnet 1   │    │  Subnet 2   │    │
         │              │  │  (AZ-1a)    │    │  (AZ-1b)    │    │
         │              │  │             │    │             │    │
         │              │  │ App/DB      │    │  App/DB     │    │
         │              │  │ Servers     │    │  Servers    │    │
         │              │  └─────────────┘    └─────────────┘    │
                        └─────────────────────────────────────────┘
```

## Project Structure

```
terraform-aws-infra/
├── backend-setup/              # Remote state backend configuration
│   ├── main.tf                # S3 bucket and DynamoDB table
│   ├── variables.tf
│   └── outputs.tf
├── modules/
│   ├── vpc/                   # VPC networking module
│   ├── security-groups/       # Security group configurations
│   ├── iam/                   # IAM roles and policies
│   └── ec2/                   # EC2 instance provisioning
├── environments/
│   ├── dev/                   # Development environment
│   ├── staging/               # Staging environment
│   └── prod/                  # Production environment
└── .gitignore
```

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- AWS account with permissions to create resources
- SSH key pair created in AWS (for EC2 access)

## Quick Start

### 1. Initialize Remote State Backend (First Time Only)

```bash
cd backend-setup
terraform init
terraform apply
```

This creates:
- S3 bucket for state storage (encrypted, versioned)
- DynamoDB table for state locking

### 2. Deploy an Environment

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

## Modules

### VPC Module

Creates a multi-AZ VPC with public and private subnets.

**Features:**
- Configurable CIDR blocks
- Public subnets with Internet Gateway
- Private subnets with optional NAT Gateway
- Automatic route table configuration

**Usage:**
```hcl
module "vpc" {
  source = "../../modules/vpc"

  project_name         = "my-project"
  environment          = "dev"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
  enable_nat_gateway   = false
}
```

### Security Groups Module

Creates layered security groups following the principle of least privilege.

**Security Groups:**
| Name | Inbound | Purpose |
|------|---------|---------|
| Bastion | SSH (22) from allowed CIDRs | Jump server access |
| Web | HTTP/HTTPS (80/443) from anywhere | Web traffic |
| App | Custom port from web SG | Application layer |
| Database | Custom port from app SG | Database layer |

**Usage:**
```hcl
module "security_groups" {
  source = "../../modules/security-groups"

  project_name      = "my-project"
  environment       = "dev"
  vpc_id            = module.vpc.vpc_id
  allowed_ssh_cidrs = ["10.0.0.0/8"]
  app_port          = 8080
  database_port     = 5432
}
```

### IAM Module

Creates EC2 instance roles with configurable permissions.

**Features:**
- SSM Session Manager access (optional)
- CloudWatch agent permissions (optional)
- S3 read-only access to specified buckets (optional)
- Custom inline policies support

**Usage:**
```hcl
module "iam" {
  source = "../../modules/iam"

  project_name       = "my-project"
  environment        = "dev"
  enable_ssm_access  = true
  enable_cloudwatch  = true
  enable_s3_read     = false
}
```

### EC2 Module

Provisions EC2 instances with security best practices.

**Features:**
- Amazon Linux 2023 AMI (default)
- IMDSv2 enforcement (enhanced security)
- Optional Elastic IP association
- Additional EBS volume support
- User data script support

**Usage:**
```hcl
module "bastion" {
  source = "../../modules/ec2"

  project_name          = "my-project"
  environment           = "dev"
  instance_name         = "bastion"
  instance_count        = 1
  instance_type         = "t3.micro"
  subnet_ids            = module.vpc.public_subnet_ids
  security_group_ids    = [module.security_groups.bastion_sg_id]
  key_name              = "my-key-pair"
  iam_instance_profile  = module.iam.ec2_instance_profile_name
  associate_elastic_ip  = true
}
```

## Environment Configuration

| Setting | Dev | Staging | Production |
|---------|-----|---------|------------|
| Region | us-east-1 | us-east-1 | us-east-1 |
| VPC CIDR | 10.0.0.0/16 | 10.0.0.0/16 | 10.0.0.0/16 |
| NAT Gateway | Disabled | Disabled | Configurable |
| Bastion Host | 1x t3.micro | 1x t3.micro | 1x t3.micro |
| Web Servers | 1x t3.micro | 1x t3.micro | 1x t3.micro |
| Detailed Monitoring | Disabled | Disabled | Enabled |

## Remote State Configuration

State is stored in S3 with DynamoDB locking:

```hcl
terraform {
  backend "s3" {
    bucket         = "nikko-terraform-state-bucket-7x9k2m"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}
```

## Common Operations

### View Current State
```bash
terraform state list
terraform state show <resource>
```

### Plan Changes
```bash
terraform plan -out=tfplan
```

### Apply Changes
```bash
terraform apply tfplan
# or
terraform apply -auto-approve  # Use with caution
```

### Destroy Infrastructure
```bash
terraform destroy
```

### Import Existing Resources
```bash
terraform import <resource_type>.<name> <resource_id>
```

## Security Features

- **Encrypted State**: S3 backend with AES256 encryption
- **State Locking**: DynamoDB prevents concurrent modifications
- **IMDSv2**: Enhanced EC2 metadata service security
- **Network Segmentation**: Public/private subnet isolation
- **Least Privilege**: Layered security groups
- **No Hardcoded Secrets**: Variables for sensitive values

## Outputs

Each module exports useful information:

```bash
# View all outputs
terraform output

# View specific output
terraform output vpc_id
terraform output bastion_public_ip
```

**Common Outputs:**
- VPC ID and subnet IDs
- Security group IDs
- IAM role ARNs and instance profile names
- EC2 instance IDs, IPs, and DNS names

## Customization

### Add New Environment

1. Copy an existing environment folder:
   ```bash
   cp -r environments/dev environments/new-env
   ```

2. Update `terraform.tfvars`:
   ```hcl
   project_name = "my-project"
   environment  = "new-env"
   # ... other variables
   ```

3. Update backend key in `main.tf`:
   ```hcl
   backend "s3" {
     key = "environments/new-env/terraform.tfstate"
   }
   ```

4. Initialize and apply:
   ```bash
   terraform init
   terraform apply
   ```

### Enable NAT Gateway

```hcl
# In terraform.tfvars
enable_nat_gateway = true
```

### Add Application Servers

```hcl
# In terraform.tfvars
app_server_count = 2
app_server_type  = "t3.small"
```

## Troubleshooting

### State Lock Issues
```bash
# Force unlock (use with caution)
terraform force-unlock <lock-id>
```

### Provider Issues
```bash
# Reinitialize providers
rm -rf .terraform
terraform init
```

### Resource Conflicts
```bash
# Refresh state from AWS
terraform refresh
```

## Best Practices

1. **Always run `terraform plan` before `apply`**
2. **Use workspaces or separate directories for environments**
3. **Never commit `.tfvars` files with secrets**
4. **Tag all resources for cost tracking**
5. **Review state changes before applying**
6. **Use `-target` sparingly**

## License

This project is for demonstration purposes.
