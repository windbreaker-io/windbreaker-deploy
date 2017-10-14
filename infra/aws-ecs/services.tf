resource "aws_ecs_service" "core" {
  name = "core"
  cluster = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.core.arn}"
  desired_count = 2
}

resource "aws_appautoscaling_target" "core" {
  max_capacity = 16
  min_capacity = 2
  resource_id = "service/${var.cluster_name}/core"
  role_arn = "${aws_iam_role.app_autoscaling.arn}"
  service_namespace = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  depends_on = [ "aws_ecs_service.core" ]
}

resource "aws_appautoscaling_policy" "core_service_scale_out" {
  name = "${var.cluster_name}/core scale out policy"
  resource_id = "service/${var.cluster_name}/core"
  service_namespace = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    cooldown = 60
    metric_aggregation_type = "Maximum"
    adjustment_type = "ChangeInCapacity"

    step_adjustment {
      metric_interval_lower_bound = 1.0
      scaling_adjustment = 1
    }
  }
  depends_on = [ "aws_appautoscaling_target.core" ]
}

resource "aws_appautoscaling_policy" "core_service_scale_in" {
  name = "${var.cluster_name}/core scale in policy"
  resource_id = "service/${var.cluster_name}/core"
  service_namespace = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    cooldown = 60
    metric_aggregation_type = "Maximum"
    adjustment_type = "ChangeInCapacity"

    step_adjustment {
      metric_interval_lower_bound = 1.0
      scaling_adjustment = -1
    }
  }
  depends_on = [ "aws_appautoscaling_target.core" ]
}

resource "aws_cloudwatch_metric_alarm" "core_cpu_high" {
  alarm_name = "core-service-high-cpu-usage-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = "120"
  statistic = "Maximum"
  threshold = "75"
  alarm_description = "Trigger scale up on high cpu usage"
  insufficient_data_actions = []
  alarm_actions = [ "${aws_appautoscaling_policy.core_service_scale_out.arn}" ]
}

resource "aws_cloudwatch_metric_alarm" "core_cpu_low" {
  alarm_name = "core-service-low-cpu-usage-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = "120"
  statistic = "Maximum"
  threshold = "25"
  alarm_description = "Trigger scale down on high cpu usage"
  insufficient_data_actions = []
  alarm_actions = [ "${aws_appautoscaling_policy.core_service_scale_in.arn}" ]
}
