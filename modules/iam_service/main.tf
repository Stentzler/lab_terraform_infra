terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    sid    = "AllowEC2AssumeRole"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "service_ec2_role" {
  name               = "${var.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-ec2-role"
      Role = "ec2-service-role"
    }
  )
}

resource "aws_iam_instance_profile" "service_ec2_profile" {
  name = "${var.name_prefix}-ec2-instance-profile"
  role = aws_iam_role.service_ec2_role.name

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-ec2-instance-profile"
      Role = "ec2-instance-profile"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.service_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.service_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}