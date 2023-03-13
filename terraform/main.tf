# main.tf
provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name      = "my-keypair"
  security_groups = ["${aws_security_group.instance.name}"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/my-keypair.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source = "../ansible"
    destination = "/home/ubuntu/"
    
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y ansible",
      "sudo ansible-playbook /home/ubuntu/ansible/playbook.yml"
    ]
  }

  tags = {
    Name = "DotNet-composed"
  }
}

resource "aws_security_group" "instance" {
  name_prefix = "instance-sg-"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
