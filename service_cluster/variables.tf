variable "region" {
  description = "The region to deploy the cluster in, e.g: us-east-1."
}

variable "project_name" {
  description = "The name of the project for tags"
}

variable "common_state_bucket" {
  description = "The bucket with the infrastructure state"
}

variable "env_state_bucket" {
  description = "The bucket with the state of this environment"
}

variable "profile" {
  description = "The AWS profile to use for deployment"
}

//  AMI Images for ECS optimised linux.
variable "ami_ecs_optimised" {
  description = "The AMI for ECS optimised"
}

variable "instance_type" {
  description = "The size of the service server nodes, e.g: t2.micro"
}

variable "min_size" {
  description = "The minimum size of the cluster, e.g. 5"
}

variable "max_size" {
  description = "The maximum size of the cluster, e.g. 5"
}

variable "vpc_sg" {
  description = "The security groups for the vpc"
}

variable "vpc_id" {
  description = "The vpc to use for the load balancer"
}

variable "public_web_sg" {
  description = "The security groups for the public ssh"
}

variable "public_ssh_sg" {
  description = "The security groups for the public ssh"
}

variable "public_subnets" {
  description = "The public subnets to use"
  type = "list"
}

variable "private_subnets" {
  description = "The private subnets to use"
  type = "list"
}

variable "env_name" {
  description = "The name of the environment to use as a prefix"
}

variable "keypair" {
  description = "The name of the keypair to use"
}
