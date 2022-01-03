variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "project_name" {
  type    = string
  default = "cm-ec2-ssl"
}

variable "public_key" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFjmigfbWPk7m6Zio4HweNGAw8Rby26vmBSbAZgDd9/7G099reoUncmI8nYSQG8XgVMGUZOixf9tQur6IQFy4Lbds4cB/THax9LmkmCBO5CtrklS73SzLj2FgTBYv3rMdRBK3pnqolatNq9q0cONdIkGqg8XiU5fFCBzextlLBikYdUsdy1rpehR/Ky0qDt1ds5X7XAqfwLXdO3If19wrWcU0WAV04RzPMxlzXdXFFImmxKzlnfeiEX15cOZ+xAnddxmjqXqD39hvTfQrDtRgNn8dF443FbOQXZgdr0N+/rcgxjGuBzlyBbxH5M0al19vnjP5D1VHTP9lS9S7+NhXN cm-ec2-key"
}
