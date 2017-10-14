resource "aws_ecs_task_definition" "core" {
  family = "${var.cluster_name}-core"
  container_definitions = "${file("container-definitions/core.json")}"
}

