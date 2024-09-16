data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]
  subnet_id              = var.subnet_id

  tags = merge(
    {
      Name = "${var.project_name}-bastion"
    },
    var.tags
  )

  user_data = <<-EOF
              #!/bin/bash
              echo "this is bastion"
              EOF

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
    encrypted   = true
  }
}

resource "aws_eip" "bastion" {
  domain   = "vpc"
  instance = aws_instance.bastion.id

  tags = {
    Name = "${var.project_name}-bastion-eip"
  }
}

resource "null_resource" "copy_ssh_key" {
  depends_on = [aws_instance.bastion]

  provisioner "file" {
    source      = var.key_path
    destination = "/home/ec2-user/.ssh/id_rsa"
    connection {
      type        = "ssh"
      host        = aws_eip.bastion.public_ip
      user        = "ec2-user"
      private_key = file(var.key_path)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ec2-user/.ssh/id_rsa"
    ]
    connection {
      type        = "ssh"
      host        = aws_eip.bastion.public_ip
      user        = "ec2-user"
      private_key = file(var.key_path)
    }
  }
}
