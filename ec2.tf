data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_ami" "amazon-linux-worker" {
  provider = aws.region-worker
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# key-pair for logging into EC2 in us-east-1
resource "aws_key_pair" "main_key" {
  provider   = aws.region-main
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}

# key-pair for logging into EC2 in us-west-2
resource "aws_key_pair" "worker_key" {
  provider   = aws.region-worker
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "jenkins_main" {
  provider                    = aws.region-main
  ami                         = data.aws_ami.amazon-linux.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.main_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins_main.id]
  subnet_id                   = aws_subnet.public_1.id
  provisioner "local-exec" {
    command = <<EOF
aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region-main} --instance-ids ${self.id} \
&& ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name}' ansible_templates/install_jenkins.yaml
EOF
  }
  tags = {
    Name = "jenkins_main_tf"
  }
  depends_on = [aws_main_route_table_association.main_default_rt_assoc]
}

resource "aws_instance" "jenkins_worker" {
  provider                    = aws.region-worker
  count                       = var.workers_count
  ami                         = data.aws_ami.amazon-linux-worker.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.worker_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins_worker.id]
  subnet_id                   = aws_subnet.public_worker_1.id
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "java -jar /home/ec2-user/jenkins-cli.jar -auth @/home/ec2-user/jenkins_auth -s http://${self.tags.Master_Private_IP}:8080 -auth @/home/ec2-user/jenkins_auth delete-node ${self.private_ip}"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }

  provisioner "local-exec" {
    command = <<EOF
aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region-worker} --instance-ids ${self.id} \
&& ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name} master_ip=${self.tags.Master_Private_IP}' ansible_templates/install_worker.yaml
EOF
  }
  tags = {
    Name              = join("_", ["jenkins_worker_tf", count.index + 1])
    Master_Private_IP = aws_instance.jenkins_main.private_ip
  }
  depends_on = [aws_main_route_table_association.worker_default_rt_assoc, aws_instance.jenkins_main]
}
