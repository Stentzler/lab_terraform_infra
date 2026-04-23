---
name: terraform-plan-review
description: Use this skill when reviewing a Terraform plan before apply. Trigger when the user shares terraform plan output, asks whether a plan is safe, asks what will be created/changed/destroyed, or wants a pre-apply review checklist. Do not trigger for general Terraform syntax questions, writing new modules, or backend/bootstrap setup unless a terraform plan output is being reviewed.
---

# Terraform Plan Review

## Goal

Review a Terraform plan before apply and identify:

- what will be created, changed, or destroyed
- whether the planned changes match the intended architecture
- risky or unexpected changes
- missing prerequisites
- validation steps after apply

## Inputs expected

The user should provide at least one of:

- `terraform plan` output
- a saved plan summary
- relevant Terraform files when the plan alone is not enough

## Review process

1. Start with a short summary:
   - total resources to add
   - total resources to change
   - total resources to destroy

2. Identify the architectural intent:
   - infer what the user is trying to achieve
   - confirm whether the plan matches that intent

3. Review by category:
   - networking
   - security groups and IAM
   - load balancing
   - compute / autoscaling
   - registries / storage
   - outputs

4. Check for dangerous changes:
   - unexpected destroys
   - replacement of stateful or expensive resources
   - public exposure that was not intended
   - mismatched ports, health checks, or subnet placement
   - resource dependency issues
   - bootstrap issues, such as instances depending on artifacts that do not exist yet

5. Call out operational risks:
   - costs
   - destroy/recreate behavior
   - DNS changes
   - health check failures
   - rollout concerns

6. End with a clear verdict:
   - safe to apply
   - safe with caveats
   - stop and fix before apply

## Review style

- Be direct and specific.
- Prefer concrete findings over generic Terraform advice.
- Use the actual plan content to support conclusions.
- Distinguish clearly between:
  - confirmed issues
  - acceptable tradeoffs
  - optional improvements

## Output format

Use this structure when possible:

1. **Summary**
2. **What looks correct**
3. **Issues to fix before apply**
4. **Acceptable tradeoffs / follow-up improvements**
5. **Post-apply validation checklist**
6. **Verdict**

## Important reminders

- Do not assume a plan is safe just because `terraform validate` passed.
- Pay special attention to:
  - route tables and subnet associations
  - ALB and target group wiring
  - ASG desired/min/max behavior
  - IAM permissions
  - bootstrap order dependencies
  - ECR tag strategy vs mutability
- If the user is intentionally optimizing for simplicity in a lab or portfolio project, prefer practical guidance over overengineering.