output "master_private_ips" {
  description = "Private IPs of the master nodes"
  value       = aws_instance.master[*].private_ip
}

output "master_public_ips" {
  description = "Public IPs of the master nodes"
  value       = aws_instance.master[*].public_ip
}

output "k3s_token_secret_arn" {
  description = "ARN of the secret storing the k3s token"
  value       = aws_secretsmanager_secret.k3s_token.arn
}