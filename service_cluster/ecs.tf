// we put the registrator and consul-agent into the autoscaling group user data
// so that there's only one running per instance. That way the tasks can be routed throughout
// the cluster wherever they are needed. With that being the case, we might be able to run more
// tasks per server. If we do that, do we need pm2? Maybe it would still be good for managing
// the memory usage of node so that it restarts when it gets too high.

resource "aws_ecs_cluster" "service_cluster" {
  name = "${var.project_name}-${var.env_name}-service"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "service_log" {
  name = "${var.project_name}-${var.env_name}-service-log"
}

output "cluster_name" {
  value = "${aws_ecs_cluster.service_cluster.name}"
}

output "log_group" {
  value = "${aws_cloudwatch_log_group.service_log.name}"
}
