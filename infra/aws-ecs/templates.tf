data "template_file" "coreos-cloud-config" {
  template = "${file("templates/coreos-cloud-config.yml")}"

  vars {
    ecs_cluster = "${aws_ecs_cluster.cluster.name}"
    ecs_loglevel = "warn"
    ecs_checkpoint = true
  }
}
