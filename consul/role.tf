resource "aws_iam_policy" "consul_server_permissions" {
  name = "${var.project_name}-${var.env_name}-consul-permissions"
  path = "/"
  description = "The permissions required for a Consul Server"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetAuthorizationToken",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:PutMetricData",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics",
        "ec2:Describe*",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

//  Create a role which consul instances will assume.
//  This role has a policy saying it can be assumed by ec2
//  instances.
resource "aws_iam_role" "consul_instance_role" {
    name = "${var.project_name}-${var.env_name}-consul-instance-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
          "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

//  Attach the policy to the role.
resource "aws_iam_policy_attachment" "consul_instance_permissions" {
  name = "${var.project_name}-${var.env_name}-consul-leader-server-policy"
  roles = ["${aws_iam_role.consul_instance_role.name}"]
  policy_arn = "${aws_iam_policy.consul_server_permissions.arn}"
}

//  Create a instance profile for the role.
resource "aws_iam_instance_profile" "consul_instance_profile" {
  name = "${var.project_name}-${var.env_name}-consul-instance-profile"
  role = "${aws_iam_role.consul_instance_role.name}"
}
