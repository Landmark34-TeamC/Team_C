provider "aws" {
  region = "us-east-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins34_sg"
  description = "Security group for Jenkins and Terraform instances"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "jenkins34"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install -y openjdk-11-jdk git
                wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
                echo "deb https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list
                sudo apt update -y
                sudo apt install -y jenkins
                sudo systemctl start jenkins
                sudo systemctl enable jenkins
                EOF

  tags = {
    Name = "Jenkins"
  }
}

resource "aws_instance" "terraform" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  key_name               = "jenkins34"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install -y git
                wget https://releases.hashicorp.com/terraform/1.8.2/terraform_1.8.2_linux_amd64.zip
                sudo apt install unzip -y
                unzip terraform_1.8.2_linux_amd64.zip
                sudo mv terraform /usr/local/bin/
                EOF

  tags = {
    Name = "Terraform"
  }
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "terraform_public_ip" {
  value = aws_instance.terraform.public_ip
}
