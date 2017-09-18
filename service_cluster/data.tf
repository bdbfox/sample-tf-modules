data "terraform_remote_state" "network" {
  backend = "s3"
  config {
    bucket          = "${var.common_state_bucket}"
    encrypt         = true
    key             = "common/network/terraform.tfstate"
    profile         = "${var.profile}"
    region          = "us-east-2"
  }
}
