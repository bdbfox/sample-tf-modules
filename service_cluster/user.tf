
resource "aws_iam_user" "service_user" {
  name    = "${var.project_name}-${var.env_name}-service-user"
  path    = "/"
}

resource "aws_iam_access_key" "service_accesskey" {
  user    = "${aws_iam_user.service_user.name}"
}

resource "aws_iam_user_policy" "service_policy" {
  name    = "${var.project_name}-${var.env_name}-service-policy"
  user    = "${aws_iam_user.service_user.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sqs:SendMessage",
        "sqs:ReceiveMessage"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

output "service_user_key" {
  value = "${aws_iam_access_key.service_accesskey.id}"
}

output "service_user_secret" {
  value = "${aws_iam_access_key.service_accesskey.secret}"
}
