//  Load balancers for our consul cluster.
resource "aws_elb" "service_lb" {
  name            = "${var.project_name}-${var.env_name}-linkerd-lb"
  internal        = false
  security_groups = [
    "${var.vpc_sg != "" ? var.vpc_sg : data.terraform_remote_state.network.vpc_sg}",
    "${var.public_web_sg != "" ? var.public_web_sg : data.terraform_remote_state.network.public_web_sg}",
  ]

  // terraform does not allow lists in conditionals
  subnets = ["${split(",", length(var.public_subnets) > 0 ? join(",", var.public_subnets) : join(",", data.terraform_remote_state.network.public_subnets))}"]
  listener {
    instance_port = 4140
    instance_protocol = "http"
    lb_port = 4140
    lb_protocol = "http"
  }

  listener {
    instance_port = 9990
    instance_protocol = "http"
    lb_port = 9990
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:9990"
    interval = 30
  }
}

output "api_load_balancer" {
  value = "${aws_elb.service_lb.dns_name}"
}
