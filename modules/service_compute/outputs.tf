output "launch_template_id" {
  description = "Launch template ID"
  value       = aws_launch_template.this.id
}

output "launch_template_latest_version" {
  description = "Latest launch template version"
  value       = aws_launch_template.this.latest_version
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.this.name
}

output "autoscaling_group_arn" {
  description = "Auto Scaling Group ARN"
  value       = aws_autoscaling_group.this.arn
}