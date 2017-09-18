data "template_file" "service_cluster_user_data" {
  template = "${file("./templates/service.tpl")}"

  vars {
    clustername = "${aws_ecs_cluster.service_cluster.name}"
    group_name = "${var.project_name}-${var.env_name}-consul"
  }
}

//  Launch configuration for the service cluster auto-scaling group.
resource "aws_launch_configuration" "service_cluster_lc" {
  name_prefix = "${var.project_name}-${var.env_name}-service-node"
  image_id = "${var.ami_ecs_optimised}"
  instance_type = "${var.instance_type}"
  user_data = "${data.template_file.service_cluster_user_data.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.service_cluster_instance_profile.id}"
  security_groups = [
    "${var.vpc_sg != "" ? var.vpc_sg : data.terraform_remote_state.network.vpc_sg}"
  ]
  lifecycle {
      create_before_destroy = true
  }
  key_name = "${var.keypair}"
}

//  Auto-scaling group for our cluster.
resource "aws_autoscaling_group" "service_cluster_asg" {
  name = "${var.project_name}-${var.env_name}-service-asg"
  launch_configuration = "${aws_launch_configuration.service_cluster_lc.name}"
  min_size = "${var.min_size}"
  max_size = "${var.max_size}"
  vpc_zone_identifier = ["${split(",", length(var.private_subnets) > 0 ? join(",", var.private_subnets) : join(",", data.terraform_remote_state.network.private_subnets))}"]
  lifecycle {
      create_before_destroy = true
  }

  load_balancers = ["${aws_elb.service_lb.name}"]
  default_cooldown = 30
  health_check_grace_period = 120

  tag {
    key = "Name"
    value = "${var.project_name}-${var.env_name}-service"
    propagate_at_launch = true
  }
  tag {
    key = "Project"
    value = "${var.project_name}"
    propagate_at_launch = true
  }
}

output "service_cluster_asg" {
  value = "${aws_autoscaling_group.service_cluster_asg.id}"
}
