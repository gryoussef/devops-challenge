output "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer"
  value       = aws_lb.k8s_api.dns_name
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.k8s_workers.dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID of the Application Load Balancer"
  value       = aws_lb.k8s_workers.zone_id
}

output "k8s_api_target_group_arn" {
  description = "ARN of the Kubernetes API target group"
  value       = aws_lb_target_group.k8s_api.arn
}

output "k8s_nodeport_target_group_arn" {
  description = "ARN of the Kubernetes NodePort target group"
  value       = aws_lb_target_group.k8s_nodeport.arn
}