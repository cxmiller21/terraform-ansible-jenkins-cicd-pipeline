# Terraform & Ansible SSL Nginx AWS EC2 Instance

Terraform + Ansible IaC to spin up an AWS EC2 instance with an SSL cert and nginx

## Goals

Use Terraform to define and manage an AWS EC2 instance that has a valid SSL cert for nginx connections over https.

## Start

```
# Generate a public ssh key and modify the public_key variable value
$ terraform init
$ terraform apply
```
