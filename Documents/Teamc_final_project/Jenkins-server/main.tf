/*
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
  description = "Security group for Jenkins instance"


  // Inbound rule to allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Inbound rule to allow HTTP access
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Outbound rule to allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"

  key_name = "jenkins34"

  tags = {
    Name = "Jenkins"
  }


  // Associate the security group with the instance
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y && sudo apt install openjdk-21-jdk -y
              sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
              wget -O- https://apt.releases.hashicorp.com/gpg | \
              gpg --dearmor | \
              sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
              echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
              https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
              sudo tee /etc/apt/sources.list.d/hashicorp.list
              wget https://releases.hashicorp.com/terraform/1.8.2/terraform_1.8.2_linux_amd64.zip
              sudo apt install unzip wget
              unzip terraform_1.8.2_linux_amd64.zip
              sudo mv terraform /usr/local/bin/
              sudo apt update -y
              sudo apt install -y jenkins
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              EOF

}

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}
*/



