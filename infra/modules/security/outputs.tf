output "bastion_sg_id" {
  description = "The ID of the bastion host security group"
  value       = aws_security_group.bastion.id
}

output "k8s_masters_sg_id" {
  description = "The ID of the Kubernetes masters security group"
  value       = aws_security_group.k8s_masters.id
}

output "k8s_workers_sg_id" {
  description = "The ID of the Kubernetes workers security group"
  value       = aws_security_group.k8s_workers.id
}

output "alb_sg_id" {
  description = "The ID of the Application Load Balancer security group"
  value       = aws_security_group.alb.id
}