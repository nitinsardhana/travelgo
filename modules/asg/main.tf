resource "aws_autoscaling_group" "web" {

  name = "${var.environment}-asg"

  desired_capacity = 1
  min_size         = 1
  max_size         = 2

  vpc_zone_identifier = [
    var.public_subnet_a_id,
    var.public_subnet_b_id
  ]

  target_group_arns = [
    var.target_group_arn
  ]

  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }

  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "${var.environment}-asg-instance"
    propagate_at_launch = true
  }
}