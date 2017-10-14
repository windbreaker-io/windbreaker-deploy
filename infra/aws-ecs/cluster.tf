resource "aws_ecs_cluster" "cluster" {
  name = "${var.cluster_name}"
}

resource "aws_launch_configuration" "cluster" {
  name = "${var.cluster_name}-ecs-container-instance-launch-configuration"
  image_id = "${module.ami.ami_id}"
  instance_type = "t2.nano"
  user_data = "${data.template_file.coreos-cloud-config.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs_container.id}"
  key_name = "${aws_key_pair.key_pair.key_name}"
  security_groups = [ "${aws_security_group.ecs_cluster.id}" ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "cluster" {
  name = "${var.cluster_name}-asg"

  launch_configuration = "${aws_launch_configuration.cluster.name}"
  min_size = 1
  max_size = 16

  vpc_zone_identifier = [ "${aws_subnet.private.*.id}" ]

  tag {
    key = "${var.cluster_name}"
    value = ""
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  # depends on cluster being created and private routes
  depends_on = [
    "aws_ecs_cluster.cluster",
    "aws_route.private",
    "aws_route_table_association.private"
  ]
}

# cluster will scale based on instance CPU reservation
# each container will take up a portion of the CPU reservation
# so the cluster gets filled with more containers, we will provision
# more instances to contain them
# for now, just use simple scaling

# trigger scale out based on cluster reservation
resource "aws_autoscaling_policy" "cluster_scale_out" {
  name = "${var.cluster_name}-scale-out-policy"
  autoscaling_group_name = "${aws_autoscaling_group.cluster.name}"
  adjustment_type = "ChangeInCapacity"
  cooldown = 60
  scaling_adjustment = 2 # scale up slightly faster
}

resource "aws_cloudwatch_metric_alarm" "cluster_instance_cpu_reservation_low" {
  alarm_name = "${var.cluster_name}-cpu-reservation-low-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "CPUReservation"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Maximum"
  threshold = "70"
  alarm_description = "Monitors lack of cpu reservation on instances"
  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.cluster.name}"
  }

  alarm_actions = [ "${aws_autoscaling_policy.cluster_scale_out.arn}" ]
}

# trigger scale in based on cluster reservation
resource "aws_autoscaling_policy" "cluster_scale_in" {
  name = "${var.cluster_name}-scale-in-policy"
  autoscaling_group_name = "${aws_autoscaling_group.cluster.name}"
  adjustment_type = "ChangeInCapacity"
  cooldown = 60
  scaling_adjustment = -1 # scale down slowly
}

resource "aws_cloudwatch_metric_alarm" "cluster_instance_cpu_reservation_high" {
  alarm_name = "${var.cluster_name}-cpu-reservation-high-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUReservation"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Maximum"
  threshold = "10"
  alarm_description = "Monitors excess cpu reservation on instances"
  insufficient_data_actions = []
  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.cluster.name}"
  }
  alarm_actions = [ "${aws_autoscaling_policy.cluster_scale_in.arn}" ]
}
