variable "account_id" {
  description = "The AWS account id"
}

variable "env_name" {
  description = "The name of the environment to use as a prefix"
}

variable "project_name" {
  description = "The name of the project for tags"
}

variable "profile" {
  description = "The AWS profile to use for deployment"
}

variable "region" {
  description = "The region to deploy the cluster in, e.g: us-east-1."
}

variable "common_state_bucket" {
  description = "The bucket with the infrastructure state"
}

variable "env_state_bucket" {
  description = "The bucket with the state of this environment"
}

variable "redis_port" {
  description = "The redis port number"
  default = 6379
}

variable "private_subnets" {
  description = "The private subnets to use"
  type = "list"
}

variable "vpc_sg" {
  description = "The security groups for the vpc"
}

variable "subnetazs" {
  type = "list"
  description = "The subnets to use"
}

variable "redis_node_type" {
  description = "The node type for the redis"
}
