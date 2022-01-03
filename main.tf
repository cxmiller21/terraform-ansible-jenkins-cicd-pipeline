data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}
