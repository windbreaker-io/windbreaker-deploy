# iam role for the ec2 container instances
resource "aws_iam_role" "ecs_container" {
  name = "${var.cluster_name}-ecs-container-instance-role"
  assume_role_policy = "${file("iam-policies/ec2-instance-assume-role.json")}"
}

resource "aws_iam_role_policy" "ecs_container" {
  name = "${var.cluster_name}-ecs-container-role-policy"
  role = "${aws_iam_role.ecs_container.id}"
  policy = "${file("iam-policies/ecs-container-instance.json")}"
}

# instance profile for containers
resource "aws_iam_instance_profile" "ecs_container" {
  name = "${var.cluster_name}-ecs-container-instance-profile"
  role = "${aws_iam_role.ecs_container.id}"
}

# iam role for autoscalling
resource "aws_iam_role" "app_autoscaling" {
  name = "${var.cluster_name}-service-autoscaling-role"
  assume_role_policy = "${file("iam-policies/app-autoscaling-assume-role.json")}"
}

resource "aws_iam_role_policy" "app_autoscaling" {
  name = "${var.cluster_name}-service-autoscaling-policy"
  role = "${aws_iam_role.app_autoscaling.id}"
  policy = "${file("iam-policies/app-autoscaling.json")}"
}
