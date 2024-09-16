# NLB for Kubernetes API
resource "aws_lb" "k8s_api" {
  name               = "${var.cluster_name}-api-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids

  enable_cross_zone_load_balancing = true

  tags = {
    Name = "${var.cluster_name}-api-nlb"
  }
}

resource "aws_lb_target_group" "k8s_api" {
  name        = "${var.cluster_name}-api-tg"
  port        = 6443
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

   health_check {
    protocol = "TCP"
    port     = "6443"
    interval = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "k8s_api" {
  load_balancer_arn = aws_lb.k8s_api.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_api.arn
  }
}

# ALB for worker nodes (NodePort)
resource "aws_lb" "k8s_workers" {
  name               = "${var.cluster_name}-workers-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.cluster_name}-workers-alb"
  }
}

resource "aws_lb_target_group" "k8s_nodeport" {
  name        = "${var.cluster_name}-nodeport-tg"
  port        = 30000  # Starting NodePort range
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/healthz"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200,301,302"
  }
}

resource "aws_lb_listener" "k8s_http" {
  load_balancer_arn = aws_lb.k8s_workers.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

data "aws_acm_certificate" "ssl_cert" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}

resource "aws_lb_listener" "k8s_https" {
  load_balancer_arn = aws_lb.k8s_workers.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.ssl_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_nodeport.arn
  }
}