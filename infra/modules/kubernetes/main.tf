data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "random_password" "k3s_token" {
  length  = 64
  special = false
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_secretsmanager_secret" "k3s_token" {
  name = "${var.project_name}-k3s-token-${random_string.suffix.result}"
}

resource "aws_secretsmanager_secret_version" "k3s_token" {
  secret_id     = aws_secretsmanager_secret.k3s_token.id
  secret_string = random_password.k3s_token.result
}

resource "aws_instance" "master0" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.master_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.master_security_group_id]
  subnet_id              = var.master_subnet_ids[0]

  tags = {
    Name = "${var.project_name}-master-1"
  }

  user_data = templatefile("${path.module}/master_userdata.sh.tmpl", {
    k3s_token       = aws_secretsmanager_secret_version.k3s_token.secret_string,
    nlb_dns_name    = var.nlb_dns_name,
    is_first_master = true
    first_master_private_ip = ""
  })

  root_block_device {
    volume_type = "gp2"
    volume_size = 20
    encrypted   = true
  }
}

resource "aws_instance" "master" {
  count                  = var.master_count - 1
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.master_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.master_security_group_id]
  subnet_id              = var.master_subnet_ids[(count.index + 1) % length(var.master_subnet_ids)]
  
  tags = {
    Name = "${var.project_name}-master-${count.index + 2}"
  }

  user_data = templatefile("${path.module}/master_userdata.sh.tmpl", {
    k3s_token               = aws_secretsmanager_secret_version.k3s_token.secret_string,
    nlb_dns_name            = var.nlb_dns_name,
    first_master_private_ip = aws_instance.master0.private_ip,
    is_first_master         = false
  })

  root_block_device {
    volume_type = "gp2"
    volume_size = 20
    encrypted   = true
  }

  depends_on = [aws_instance.master0]
}

resource "aws_launch_template" "worker" {
  name_prefix   = "${var.project_name}-worker-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.worker_instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [var.worker_security_group_id]

  user_data = base64encode(templatefile("${path.module}/worker_userdata.sh.tmpl", {
    k3s_token   = aws_secretsmanager_secret_version.k3s_token.secret_string,
    nlb_dns_name = var.nlb_dns_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-worker"
    }
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 8
      volume_type = "gp2"
      encrypted   = true
    }
  }
}

resource "aws_autoscaling_group" "workers" {
  name                = "${var.project_name}-workers"
  vpc_zone_identifier = var.worker_subnet_ids
  min_size            = var.min_worker_count
  max_size            = var.max_worker_count
  desired_capacity    = var.desired_worker_count

  launch_template {
    id      = aws_launch_template.worker.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-worker"
    propagate_at_launch = true
  }
}

# Attach first master node
resource "aws_lb_target_group_attachment" "master0" {
  target_group_arn = var.k8s_api_target_group_arn
  target_id        = aws_instance.master0.id
  port             = 6443
}

# Attach subsequent master nodes
resource "aws_lb_target_group_attachment" "master" {
  count            = var.master_count - 1
  target_group_arn = var.k8s_api_target_group_arn
  target_id        = aws_instance.master[count.index].id
  port             = 6443
}

resource "aws_autoscaling_attachment" "workers" {
  autoscaling_group_name = aws_autoscaling_group.workers.name
  lb_target_group_arn    = var.k8s_nodeport_target_group_arn
}

resource "null_resource" "copy_kubeconfig_to_bastion" {
  depends_on = [aws_instance.master0]

  provisioner "remote-exec" {
    inline = [
      # Create .kube directory
      "mkdir -p ~/.kube",
      
      # Copy kubeconfig
      "ssh -i /home/ec2-user/.ssh/id_rsa -o StrictHostKeyChecking=no ubuntu@${aws_instance.master0.private_ip} 'sudo cat /etc/rancher/k3s/k3s.yaml' > ~/.kube/config",
      
      # Modify the kubeconfig
      "sed -i 's/127.0.0.1/${var.nlb_dns_name}/g' ~/.kube/config",
      
      # Set correct permissions for kubeconfig
      "chmod 600 ~/.kube/config",
      
      # Verify the kubeconfig file exists
      "ls -l ~/.kube/config || echo 'Failed to copy kubeconfig'"
    ]
    
    connection {
      type        = "ssh"
      host        = var.bastion_public_ip
      user        = "ec2-user"
      private_key = file(var.key_path)
    }
  }
}