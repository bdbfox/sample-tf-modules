variable "account_id" {
  description = "The AWS account id"
}

variable "env_name" {
  description = "The name of the environment to use as a prefix"
}

variable "profile" {
  description = "The name of the aws profile to use"
}

variable "project_name" {
  description = "The name of the project for tags"
}

variable "region" {
  description = "The region to deploy the cluster in, e.g: us-east-1."
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC, e.g: 10.0.0.0/16"
}

variable "subnetaz1" {
  description = "The AZ for the first public subnet, e.g: us-east-1a"
}

variable "subnetaz2" {
  description = "The AZ for the second public subnet, e.g: us-east-1b"
}

variable "subnetaz3" {
  description = "The AZ for the third public subnet, e.g: us-east-1c"
}

variable "private_subnet_cidr1" {
  description = "The CIDR block for the first private subnet, e.g: 10.0.1.0/24"
}

variable "private_subnet_cidr2" {
  description = "The CIDR block for the second private subnet, e.g: 10.0.2.0/24"
}

variable "private_subnet_cidr3" {
  description = "The CIDR block for the second private subnet, e.g: 10.0.3.0/24"
}

variable "public_subnet_cidr1" {
  description = "The CIDR block for the first public subnet, e.g: 10.0.11.0/24"
}

variable "public_subnet_cidr2" {
  description = "The CIDR block for the second public subnet, e.g: 10.0.12.0/24"
}

variable "public_subnet_cidr3" {
  description = "The CIDR block for the second public subnet, e.g: 10.0.13.0/24"
}
