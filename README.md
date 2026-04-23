# Infra Service

Terraform infrastructure for the `lab-cicd-pipeline` service.

This repository is responsible for provisioning the AWS infrastructure required to run the application. Application image build and deployment are intentionally handled by a separate process or repository.

## Goal

Provision a clean and modular AWS foundation for the service with:

- Custom VPC
- Public and private subnets
- Internet Gateway
- NAT Gateway
- Application Load Balancer
- Auto Scaling Group
- EC2 instances
- IAM role and instance profile
- Amazon ECR repository

The application deployment flow is separated from Terraform:

- Terraform creates the infrastructure
- Another pipeline builds the Docker image
- That pipeline pushes the image to ECR
- That pipeline updates the running EC2 instances

## Current Architecture

- **ECR** stores the application image
- **ALB** receives public HTTP traffic
- **ASG** manages EC2 instances
- **EC2** instances run the containerized application
- **Custom VPC** provides network isolation
- **Public subnets** host internet-facing components
- **Private subnets** host the application instances
- **NAT Gateway** allows outbound internet access from private subnets

## Repository Structure

```text
infra-service/
├── bootstrap/
│   └── tfstate/
├── modules/
│   ├── alb/
│   ├── ecr/
│   ├── iam_service/
│   ├── network/
│   ├── security_groups/
│   └── service_compute/
├── envs/
│   ├── staging/
│   └── prod/
└── README.md
```

---

## Bootstrap

The `bootstrap/tfstate` directory exists to create the Terraform remote state backend itself.

Terraform cannot use an S3 backend until that S3 bucket already exists, so the backend resources must be created first.

### What bootstrap creates

Currently, bootstrap creates:

- one S3 bucket for the `staging` Terraform state
- one S3 bucket for the `prod` Terraform state
- versioning enabled
- encryption enabled
- public access blocked

### Why this exists

This allows each environment to use:

- remote state
- isolated state storage
- safer collaboration
- state history via S3 versioning

### Files inside `bootstrap/tfstate`

- `versions.tf`  
  Declares the required Terraform and AWS provider versions.

- `variables.tf`  
  Declares inputs used to create the backend resources, such as project name, region, and tags.

- `main.tf`  
  Creates the S3 buckets and their configurations.

- `outputs.tf`  
  Exposes useful values such as the bucket names.

---

## Environments

Each environment under `envs/` is a root Terraform module.

Right now, the intended environments are:

- `staging`
- `prod`

Each environment is responsible for composing the reusable modules and defining the concrete values used for that environment.

### Files inside each environment

#### `backend.tf`
Declares that this environment uses the `s3` Terraform backend.

#### `backend.hcl`
Stores the backend configuration for that environment, such as:

- backend bucket name
- state file key
- region
- `use_lockfile = true`

#### `versions.tf`
Pins the Terraform version and AWS provider version.

#### `providers.tf`
Configures the AWS provider and default tags.

#### `locals.tf`
Defines local computed values such as:

- environment name
- service name
- name prefix
- shared/common tags

#### `variables.tf`
Declares the inputs expected by that environment.

Examples:
- AWS region
- instance type
- app port
- ASG sizes
- VPC CIDR
- subnet CIDRs
- availability zones

#### `terraform.tfvars`
Provides the real values for the environment.

This is where the environment is customized.

#### `main.tf`
Composes the modules and wires them together.

This is the file that connects:

- network
- security groups
- IAM
- ECR
- ALB
- compute

#### `outputs.tf`
Exposes useful information after apply, such as:

- VPC ID
- subnet IDs
- ALB DNS name
- ECR repository URL
- Auto Scaling Group name

---

## Modules

The reusable logic lives inside `modules/`.

Each module has the standard Terraform structure:

- `main.tf`
- `variables.tf`
- `outputs.tf`

### 1. `modules/network`

Creates the base networking layer.

#### What it creates

- VPC
- 2 public subnets
- 2 private subnets
- Internet Gateway
- Elastic IP for NAT
- NAT Gateway
- public route table
- private route table
- route table associations

#### Why it exists

This module makes the environment self-contained and avoids depending on manually created VPCs or subnets.

#### Main configurable inputs

- `name_prefix`
- `vpc_cidr`
- `availability_zones`
- `public_subnet_cidrs`
- `private_subnet_cidrs`
- `tags`

#### Main outputs

- `vpc_id`
- `public_subnet_ids`
- `private_subnet_ids`
- `internet_gateway_id`
- `nat_gateway_id`

---

### 2. `modules/security_groups`

Creates the security groups for the ALB and EC2 instances.

#### What it creates

- ALB security group
- EC2 security group

#### Current rules

- ALB allows inbound HTTP on port `80` from the internet
- EC2 allows inbound application traffic only from the ALB security group
- both allow outbound traffic

#### Main configurable inputs

- `name_prefix`
- `vpc_id`
- `app_port`
- `tags`

#### Main outputs

- `alb_security_group_id`
- `ec2_security_group_id`

---

### 3. `modules/iam_service`

Creates the IAM resources required by the EC2 instances.

#### What it creates

- IAM role for EC2
- instance profile
- policy attachments

#### Current policy attachments

- `AmazonEC2ContainerRegistryReadOnly`
- `AmazonSSMManagedInstanceCore`

#### Why this exists

This allows EC2 instances to:

- pull images from ECR
- be managed with AWS Systems Manager

#### Main configurable inputs

- `name_prefix`
- `tags`

#### Main outputs

- `instance_profile_name`
- `instance_profile_arn`
- `role_name`
- `role_arn`

---

### 4. `modules/ecr`

Creates the Amazon ECR repository used by the service.

#### What it creates

- ECR repository
- lifecycle policy

#### Current behavior

- scan on push enabled
- encryption enabled
- repository tag mutability is configurable
- lifecycle policy keeps only the latest tagged images according to the configured limit

#### Main configurable inputs

- `repository_name`
- `image_tag_mutability`
- `keep_last_images`
- `tags`

#### Main outputs

- `repository_name`
- `repository_arn`
- `repository_url`

---

### 5. `modules/alb`

Creates the public Application Load Balancer layer.

#### What it creates

- internet-facing ALB
- target group
- HTTP listener on port `80`

#### Current behavior

- listener forwards traffic to the target group
- target group uses:
  - protocol `HTTP`
  - target type `instance`
  - health check path configurable via variable

#### Main configurable inputs

- `name_prefix`
- `vpc_id`
- `public_subnet_ids`
- `alb_security_group_id`
- `app_port`
- `health_check_path`
- `tags`

#### Main outputs

- `alb_arn`
- `alb_dns_name`
- `alb_zone_id`
- `target_group_arn`
- `listener_arn`

---

### 6. `modules/service_compute`

Creates the compute layer.

#### What it creates

- launch template
- Auto Scaling Group

#### Current behavior

- uses Amazon Linux 2023 AMI from AWS public SSM parameter
- configures the EC2 instance profile
- attaches the EC2 security group
- places instances in private subnets
- associates the ASG with the ALB target group
- uses EC2 user data to bootstrap the instance and run the container

#### Main configurable inputs

- `name_prefix`
- `subnet_ids`
- `ec2_security_group_id`
- `instance_profile_name`
- `target_group_arn`
- `instance_type`
- `asg_min_size`
- `asg_desired_capacity`
- `asg_max_size`
- `repository_url`
- `container_image_tag`
- `app_port`
- `aws_region`
- `ami_ssm_parameter_name`
- `tags`

#### Main outputs

- `launch_template_id`
- `launch_template_latest_version`
- `autoscaling_group_name`
- `autoscaling_group_arn`

---

## Environment Configuration

The main environment customization happens in `terraform.tfvars`.

### Example values currently used for staging

```hcl
aws_region           = "us-east-1"
service_name         = "lab-cicd-pipeline"
instance_type        = "t3.small"
app_port             = 8000
health_check_path    = "/health"
asg_min_size         = 1
asg_desired_capacity = 1
asg_max_size         = 2

vpc_cidr             = "10.10.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]

container_image_tag = "latest"
keep_last_images    = 10

extra_tags = {
  owner = "stentzler"
}
```

### What these values control

- `aws_region`  
  Region where the environment is created.

- `service_name`  
  Logical name of the service used in naming resources.

- `instance_type`  
  EC2 instance type used by the launch template.

- `app_port`  
  Port where the application listens inside the instance.

- `health_check_path`  
  ALB target group health check path.

- `asg_min_size`, `asg_desired_capacity`, `asg_max_size`  
  Auto Scaling Group limits and desired instance count.

- `vpc_cidr`  
  CIDR block of the custom VPC.

- `availability_zones`  
  Availability Zones used by the subnets.

- `public_subnet_cidrs`  
  CIDR ranges for public subnets.

- `private_subnet_cidrs`  
  CIDR ranges for private subnets.

- `container_image_tag`  
  The image tag the EC2 bootstrap currently tries to run. Right now, the simplified flow uses `latest`.

- `keep_last_images`  
  Number of images kept by the ECR lifecycle policy.

- `extra_tags`  
  Additional tags merged with the common tags.

---

## Deployment Strategy

This repository does **not** build or release the application image.

That is intentionally handled by another pipeline/application.

### Current simplified strategy

- Terraform creates the ECR repository
- Terraform provisions the infrastructure
- Another pipeline:
  - builds the Docker image
  - pushes `latest`
  - may also push a version tag such as `release-v0.0.1`

This allows:

- EC2 bootstrap to use `latest`
- version history to still exist in ECR through additional tags
- future rollback strategies

---

## First Bootstrap Sequence

There is one important detail on the very first infrastructure creation:

The ECR repository does not exist until Terraform creates it.

That means the very first EC2 instance should **not** start before the first image is pushed to ECR.

### Recommended first bootstrap flow

1. Set the ASG desired capacity to zero in `terraform.tfvars`

```hcl
asg_min_size         = 0
asg_desired_capacity = 0
asg_max_size         = 2
```

2. Apply Terraform

```bash
terraform apply
```

3. Push the first image to the newly created ECR repository as `latest`

4. Change the ASG values back to start instances

```hcl
asg_min_size         = 1
asg_desired_capacity = 1
asg_max_size         = 2
```

5. Apply Terraform again

```bash
terraform apply
```

### Why this is needed

Because without this sequence:

- Terraform would create the ECR repository and the EC2 instances in the same apply
- the first EC2 instance could boot before any image exists in ECR
- the bootstrap script would fail when trying to pull the image

---

## Standard Workflow

### Bootstrap remote state

From `bootstrap/tfstate`:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

### Initialize an environment

From `envs/staging` or `envs/prod`:

```bash
terraform init -backend-config=backend.hcl
terraform fmt -recursive
terraform validate
terraform plan -out=staging-bootstrap.tfplan
```

### Apply the environment

```bash
terraform apply staging-bootstrap.tfplan
```

---

## Current Design Notes

### Mutable ECR repository
The repository is currently configured as mutable so the deployment pipeline can keep updating the `latest` tag.

This is the chosen simplification for now.

### Version tags can still be used
Even though `latest` is used for bootstrap, the deployment pipeline can also push release tags, such as:

```text
lab-cicd-pipeline-staging:latest
lab-cicd-pipeline-staging:release-v0.0.1
```

That gives traceability and rollback options while keeping the simplified bootstrap flow.

### NAT Gateway strategy
The current network module creates **one NAT Gateway** for the environment.

This is acceptable for staging and for a first version, but it is not the most resilient pattern for production. A future improvement could be using one NAT Gateway per Availability Zone.

### HTTP only
The ALB currently uses HTTP on port `80`.

A future improvement for production is:

- ACM certificate
- HTTPS listener on `443`
- redirect from `80` to `443`

---

## Suggested Next Improvements

Possible future improvements after the initial infrastructure is stable:

- add HTTPS with ACM
- add Route 53 integration
- improve NAT architecture for production
- add CloudWatch alarms and monitoring
- add instance refresh or a stronger deployment integration
- move from bootstrap-on-boot to a more explicit deployment mechanism
- create separate production values under `envs/prod`

---

## Summary

This repository provisions the cloud infrastructure for the service in a modular way.

It separates:

- infrastructure provisioning
- application image build and deployment

The current foundation includes:

- remote Terraform state
- custom VPC and subnet layout
- ALB
- ASG and EC2
- IAM integration
- ECR repository
- environment-based structure

This makes the infrastructure reproducible, easier to reason about, and ready to be integrated with a separate deployment process.