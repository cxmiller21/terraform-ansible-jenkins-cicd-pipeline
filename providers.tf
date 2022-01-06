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
