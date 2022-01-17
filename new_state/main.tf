terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.24.1"
    }
  }
  required_version = ">= 0.15.2"
}

provider "aws" {
  region = var.aws_region
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

data "terraform_remote_state" "root" {
  backend = "local"

  config = {
    path = "../terraform.tfstate"
  }
}

resource "aws_instance" "example_new" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.ec2_instance_type
  vpc_security_group_ids = [data.terraform_remote_state.root.outputs.security_group]
  user_data              = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  tags = {
    Name = "Second deployment"
  }
}


output "public_ip" {
  value       = aws_instance.example_new.public_ip
  description = "The public IP of the web server"
}

output "security_group" {
  value = data.terraform_remote_state.root.outputs.security_group
}
