output "bastion_public_ip" {
  description = "The public IP of the bastion host"
  value       = aws_eip.bastion.public_ip
}

output "bastion_instance_id" {
  description = "The instance ID of the bastion host"
  value       = aws_instance.bastion.id
}