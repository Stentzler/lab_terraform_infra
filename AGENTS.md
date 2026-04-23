# AGENTS.md

## Project purpose

This repository provisions AWS infrastructure for the `lab-cicd-pipeline` service using Terraform.

The current architecture includes:

- custom VPC
- 2 public subnets
- 2 private subnets
- Internet Gateway
- 1 NAT Gateway
- Application Load Balancer
- Auto Scaling Group
- EC2 instances
- IAM role + instance profile
- Amazon ECR repository
- remote Terraform state in S3 created by bootstrap

This repository is focused on **infrastructure provisioning**.

Application build and deployment are handled outside this repository.

## High-level architecture

Current intended flow:

- ECR stores the application image
- ALB receives public HTTP traffic
- ASG manages EC2 instances
- EC2 instances run the containerized application
- ALB forwards traffic to the target group
- target group health check uses:
  - port `8000`
  - path `/health`

Current staging network:

- VPC CIDR: `10.10.0.0/16`
- public subnets:
  - `10.10.1.0/24` in `us-east-1a`
  - `10.10.2.0/24` in `us-east-1b`
- private subnets:
  - `10.10.11.0/24` in `us-east-1a`
  - `10.10.12.0/24` in `us-east-1b`

## Repository structure

```text
bootstrap/tfstate/     # creates remote Terraform state buckets
modules/               # reusable Terraform modules
envs/staging/          # staging root module
envs/prod/             # prod root module
.codex/config.toml     # project-scoped Codex config
AGENTS.md              # project instructions for Codex
```

## Important implementation rules

1. Treat this repository as **infra-only**.
   - Do not redesign it around application deployment logic unless explicitly asked.
   - The deployment pipeline is external.

2. Keep the architecture **simple and portfolio-friendly**.
   - Prefer readability and clear module boundaries over overengineering.
   - Avoid adding persistent/ephemeral stack splits unless explicitly requested.

3. Always preserve the current module pattern:
   - `network`
   - `security_groups`
   - `iam_service`
   - `ecr`
   - `alb`
   - `service_compute`

4. Prefer improving the existing design over replacing it wholesale.

5. When changing infrastructure:
   - check the current Terraform module interactions first
   - verify whether a change belongs in:
     - a reusable module
     - an environment root module
     - bootstrap

## MCP usage rules

Before implementing new infrastructure changes, consult the configured MCP servers when relevant.

Use the AWS MCP for:
- validating current AWS resource behavior
- checking service-specific implementation details
- confirming runtime resource assumptions

Use the Terraform MCP for:
- checking Terraform resource behavior
- validating schema and arguments
- confirming recommended resource usage

Do not guess resource arguments or provider behavior when MCP can verify them.

### aws_api
Use for Codex to help inspect:
- VPCs
- subnets
- route tables
- ALB / target groups
- ASG / EC2
- ECR

### aws_iac
Use for AWS-side guidance for:
- infrastructure patterns
- architecture decisions
- service interactions

### aws_docs
Use for:
- official AWS documentation context
- service-specific limits or behavior
- implementation details instead of general web search

### terraform
Use for:
- Terraform provider/resource argument validation
- Terraform Registry knowledge
- module/resource behavior checks


## Terraform conventions

- keep root environment configuration under `envs/`
- keep reusable logic under `modules/`
- keep bootstrap separate from service infrastructure
- prefer explicit variables and outputs
- keep naming/tagging consistent through locals and provider default tags
- use `terraform fmt` and `terraform validate` after changes
- prefer plans before applies
- preserve remote state configuration

## Current environment behavior

Current staging behavior:

- ECR repository is mutable
- `latest` is currently used as the bootstrap image tag
- the deployment pipeline may also push version tags
- first bootstrap flow was:
  1. apply infra with ASG desired capacity = 0
  2. push first image to ECR as `latest`
  3. raise ASG desired capacity to 1
  4. apply again

## AWS validation checklist

When validating the environment through AWS:

1. Auto Scaling Group
   - exists
   - desired capacity is correct
   - instance count is correct

2. EC2 instance
   - exists
   - running
   - inside the expected private subnet

3. Target Group
   - instance registered
   - port `8000`
   - health status is `healthy`

4. Load Balancer
   - internet-facing
   - attached to public subnets
   - listener forwards to the correct target group

## Preferred agent behavior

When asked to implement something new:

1. explain where the change belongs
2. minimize unnecessary refactors
3. preserve the current architecture unless the user asks for a redesign
4. use MCP verification before introducing new AWS or Terraform behavior
5. keep outputs and validation steps practical