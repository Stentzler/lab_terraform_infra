output "instance_profile_name" {
  description = "IAM instance profile name for the service EC2 instances"
  value       = aws_iam_instance_profile.service_ec2_profile.name
}

output "instance_profile_arn" {
  description = "IAM instance profile ARN for the service EC2 instances"
  value       = aws_iam_instance_profile.service_ec2_profile.arn
}

output "role_name" {
  description = "IAM role name attached to the EC2 instances"
  value       = aws_iam_role.service_ec2_role.name
}

output "role_arn" {
  description = "IAM role ARN attached to the EC2 instances"
  value       = aws_iam_role.service_ec2_role.arn
}