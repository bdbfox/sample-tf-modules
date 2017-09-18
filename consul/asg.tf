data "template_file" "consul_user_data" {
  template = "${file("./templates/consul.tpl")}"

  vars {
    clustername = "${aws_ecs_cluster.consul.name}"
  }
}

//  Launch configuration for the consul cluster auto-scaling group.
resource "aws_launch_configuration" "consul_cluster_lc" {
  name_prefix = "${var.project_name}-${var.env_name}-consulnode"
  image_id = "${var.ami_ecs_optimised}"
  instance_type = "${var.instance_type}"
  user_data = "${data.template_file.consul_user_data.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.consul_instance_profile.id}"
  security_groups = [
    "${var.vpc_sg != "" ? var.vpc_sg : data.terraform_remote_state.network.vpc_sg}",
    "${var.public_web_sg != "" ? var.public_web_sg : data.terraform_remote_state.network.public_web_sg}",
    "${var.public_ssh_sg != "" ? var.public_ssh_sg : data.terraform_remote_state.network.public_ssh_sg}",
  ]
  lifecycle {
      create_before_destroy = true
  }
  key_name = "${var.keypair}"
}

//  Load balancers for our consul cluster.
resource "aws_elb" "consul_lb" {
  name = "${var.project_name}-${var.env_name}-consul-lb"
  security_groups = [
    "${var.vpc_sg != "" ? var.vpc_sg : data.terraform_remote_state.network.vpc_sg}",
    "${var.public_web_sg != "" ? var.public_web_sg : data.terraform_remote_state.network.public_web_sg}"
  ]
  // terraform does not allow lists in conditionals
  subnets = ["${split(",", length(var.public_subnets) > 0 ? join(",", var.public_subnets) : join(",", data.terraform_remote_state.network.public_subnets))}"]
  listener {
    instance_port = 8500
    instance_protocol = "http"
    lb_port = 8500
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8500/ui/"
    interval = 30
  }
}

//  Auto-scaling group for our cluster.
resource "aws_autoscaling_group" "consul_cluster_asg" {
  name = "${var.project_name}-${var.env_name}-consul"
  launch_configuration = "${aws_launch_configuration.consul_cluster_lc.name}"
  min_size = 3
  max_size = 3
  // terraform does not allow lists in conditionals
  vpc_zone_identifier = ["${split(",", length(var.private_subnets) > 0 ? join(",", var.private_subnets) : join(",", data.terraform_remote_state.network.private_subnets))}"]
  load_balancers = ["${aws_elb.consul_lb.name}"]
  lifecycle {
      create_before_destroy = true
  }
  tag {
    key = "Name"
    value = "consul-${var.env_name}"
    propagate_at_launch = true
  }
  tag {
    key = "Project"
    value = "${var.project_name}"
    propagate_at_launch = true
  }
}

output "consul_dns" {
    value = "${aws_elb.consul_lb.dns_name}"
}
