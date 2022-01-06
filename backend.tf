terraform {
  required_version = ">= 1.0"
  backend "s3" {
    region  = "us-east-1"
    profile = "default"
    key     = "terraformstatefile"
    bucket  = "terraform-remote-state-2211"
  }
}