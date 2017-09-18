output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_sg" {
  value = "${aws_security_group.vpc_sg.id}"
}

output "public_web_sg" {
  value = "${aws_security_group.public_web_sg.id}"
}

output "fox_web_sg" {
  value = "${aws_security_group.fox_web_sg.id}"
}

output "public_ssh_sg" {
  value = "${aws_security_group.public_ssh_sg.id}"
}

output "public_subnets" {
  value = ["${aws_subnet.public_a.id}", "${aws_subnet.public_b.id}", "${aws_subnet.public_c.id}"]
}

output "private_subnets" {
  value = ["${aws_subnet.private_a.id}", "${aws_subnet.private_b.id}", "${aws_subnet.private_c.id}"]
}

output "nat_gateway_ip" {
  value = "${aws_eip.nat_eip.public_ip}"
}

output "bastion_access" {
  value = "ec2-user@${aws_eip.bastion_eip.public_ip}"
}

output "bastion_eip_id" {
  value = "${aws_eip.bastion_eip.id}"
}

output "bastion_ip" {
  value = "${aws_eip.bastion_eip.public_ip}"
}
