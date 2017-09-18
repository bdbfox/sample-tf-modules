resource "aws_ecs_task_definition" "consul_server" {
  family = "${var.project_name}-${var.env_name}-consul"

  network_mode = "host"

  container_definitions = <<EOF
[{
	"name": "consul-server",
	"image": "consul:0.9.3",
	"essential": true,
	"memory": 256,
	"memoryReservation": 128,
	"command": [
		"agent",
		"-server",
		"-client=0.0.0.0",
		"-bootstrap-expect=3",
		"-ui",
		"-datacenter=dc0",
		"-retry-join-ec2-tag-key=aws:autoscaling:groupName",
		"-retry-join-ec2-tag-value=${var.project_name}-consul-${var.env_name}",
    "-retry-join-ec2-region=${var.region}"
	],
	"environment": [{
		"name": "CONSUL_BIND_INTERFACE",
		"value": "eth0"
	}],
	"portMappings": [{
			"containerPort": 8300,
			"hostPort": 8300,
			"protocol": "tcp"
		},
		{
			"containerPort": 8301,
			"hostPort": 8301,
			"protocol": "tcp"
		},
		{
			"containerPort": 8302,
			"hostPort": 8302,
			"protocol": "tcp"
		},
		{
			"containerPort": 8301,
			"hostPort": 8301,
			"protocol": "udp"
		},
		{
			"containerPort": 8302,
			"hostPort": 8302,
			"protocol": "udp"
		},
		{
			"containerPort": 8400,
			"hostPort": 8400,
			"protocol": "tcp"
		},
		{
			"containerPort": 8500,
			"hostPort": 8500,
			"protocol": "tcp"
		},
		{
			"containerPort": 8600,
			"hostPort": 8600,
			"protocol": "udp"
		}
	],
	"logConfiguration": {
		"logDriver": "awslogs",
		"options": {
			"awslogs-group": "${aws_cloudwatch_log_group.consul_log.name}",
			"awslogs-region": "${var.region}",
			"awslogs-stream-prefix": "consul"
		}
	}
}]
EOF

}

resource "aws_ecs_cluster" "consul" {
  name = "${var.project_name}-${var.env_name}-consul"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "consul_log" {
  name = "${var.project_name}-${var.env_name}-consul"
}

resource "aws_ecs_service" "consul_server" {
  name = "${var.project_name}-${var.env_name}-consul-server"
  cluster = "${aws_ecs_cluster.consul.id}"
  task_definition = "${aws_ecs_task_definition.consul_server.arn}"
  desired_count = "3"
}
