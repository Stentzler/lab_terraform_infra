terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_ssm_parameter" "ami" {
  name = var.ami_ssm_parameter_name
}

locals {
  container_image = "${var.repository_url}:${var.container_image_tag}"

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    aws_region      = var.aws_region
    repository_url  = var.repository_url
    container_image = local.container_image
    app_port        = var.app_port
  }))
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = data.aws_ssm_parameter.ami.value
  instance_type = var.instance_type

  vpc_security_group_ids = [var.ec2_security_group_id]
  update_default_version = true

  iam_instance_profile {
    name = var.instance_profile_name
  }

  user_data = local.user_data

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        Name = "${var.name_prefix}-instance"
        Role = "service-instance"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.tags,
      {
        Name = "${var.name_prefix}-volume"
        Role = "service-volume"
      }
    )
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-launch-template"
      Role = "launch-template"
    }
  )
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.name_prefix}-asg"
  min_size                  = var.asg_min_size
  desired_capacity          = var.asg_desired_capacity
  max_size                  = var.asg_max_size
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = "ELB"
  health_check_grace_period = 120
  target_group_arns         = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-asg-instance"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}