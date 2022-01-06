variable "profile" {
  type    = string
  default = "default"
}

variable "region-main" {
  default = "us-east-1"
}

variable "region-worker" {
  default = "us-east-2"
}

variable "project-name" {
  type    = string
  default = "cm-tf-ansible-jenkins-cicd"
}
