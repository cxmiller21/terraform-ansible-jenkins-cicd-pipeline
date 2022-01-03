data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "cm-ec2-key"
  public_key = var.public_key
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "ec2_sg" {
  name   = "EC2-SG"
  vpc_id = aws_vpc.main.id

  ingress = [
    {
      cidr_blocks      = ["${chomp(data.http.myip.body)}/32"]
      description      = "Allow inboud SSH from local IP"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
      tags = {
        Name = "Allow inbound SSH from local IP"
      }
    }
    // {
    //   cidr_blocks      = ["0.0.0.0/0"]
    //   description      = "Allow TLS connections"
    //   from_port        = 443
    //   ipv6_cidr_blocks = []
    //   prefix_list_ids  = []
    //   protocol         = "tcp"
    //   security_groups  = []
    //   self             = false
    //   to_port          = 443
    //   tags = {
    //     Name = "Allow inbound TLS"
    //   }
  ]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Egress"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = -1
    self             = false
    security_groups  = []
    to_port          = 0
  }]

}

resource "aws_iam_instance_profile" "main" {
  name = "EC2_SSH-Profile"
  role = aws_iam_role.main.name
}

resource "aws_iam_role" "main" {
  name = "cm-ec2-ssh-role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_instance" "nginx" {
  ami                         = data.aws_ami.amazon-linux.id
  iam_instance_profile        = aws_iam_instance_profile.main.name
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh_key.key_name
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  security_groups             = [aws_security_group.ec2_sg.id]

  //   provisioner "remote-exec" {
  //     inline = [
  //         "",
  //     ]
  //   }

  connection {
    type  = "ssh"
    host  = self.public_ip
    user  = "ec2-user"
    agent = true
  }

  tags = {
    Name = "cm-ec2-ssh-instance"
  }
}

output "ec2_public_ip" {
  value = aws_instance.nginx.public_ip
}
