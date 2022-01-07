# Work around for terraform provider issue asking for an aws region
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  profile = var.profile
  region  = var.region-main
  alias   = "region-main"
}

provider "aws" {
  profile = var.profile
  region  = var.region-worker
  alias   = "region-worker"
}
