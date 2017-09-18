resource "aws_iam_policy" "service_cluster_permissions" {
  name = "${var.project_name}-${var.env_name}-cluster-permissions"
  path = "/"
  description = "The permissions required for the services"
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

//  Create a role which service instances will assume.
//  This role has a policy saying it can be assumed by ec2
//  instances.
resource "aws_iam_role" "service_cluster_instance_role" {
    name = "${var.project_name}-${var.env_name}-service-instance-role"
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

//  Create a role which the service can assume.
resource "aws_iam_role" "service_role" {
    name = "${var.project_name}-${var.env_name}-service-role"
    assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "service_permissions" {
  name = "${var.project_name}-${var.env_name}-service-permissions"
  path = "/"
  description = "The permissions required for the service"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

//  Attach the policy to the role.
resource "aws_iam_policy_attachment" "service_permissions" {
  name = "${var.project_name}-${var.env_name}-service-policy"
  roles = ["${aws_iam_role.service_role.name}"]
  policy_arn = "${aws_iam_policy.service_permissions.arn}"
}

//  Attach the policy to the role.
resource "aws_iam_policy_attachment" "service_cluster_instance_permissions" {
  name = "${var.project_name}-${var.env_name}-service-leader-server-policy"
  roles = ["${aws_iam_role.service_cluster_instance_role.name}"]
  policy_arn = "${aws_iam_policy.service_cluster_permissions.arn}"
}

//  Create a instance profile for the role.
resource "aws_iam_instance_profile" "service_cluster_instance_profile" {
  name = "${var.project_name}-${var.env_name}-service-instance-profile"
  role = "${aws_iam_role.service_cluster_instance_role.name}"
}

output "service_role_name" {
  value = "${aws_iam_role.service_role.name}"
}
