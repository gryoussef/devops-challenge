variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "master_subnet_ids" {
  description = "List of subnet IDs for master nodes"
  type        = list(string)
}

variable "worker_subnet_ids" {
  description = "List of subnet IDs for worker nodes"
  type        = list(string)
}

variable "master_security_group_id" {
  description = "Security group ID for master nodes"
  type        = string
}

variable "worker_security_group_id" {
  description = "Security group ID for worker nodes"
  type        = string
}

variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
}

variable "master_instance_type" {
  description = "Instance type for master nodes"
  type        = string
  default     = "t3.small"
}

variable "worker_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "t3.small"
}

variable "master_count" {
  description = "Number of master nodes"
  type        = number
  default     = 3
}

variable "min_worker_count" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "max_worker_count" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "desired_worker_count" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 3
}

variable "k8s_api_target_group_arn" {
  description = "ARN of the Kubernetes API target group"
  type        = string
}

variable "k8s_nodeport_target_group_arn" {
  description = "ARN of the Kubernetes NodePort target group"
  type        = string
}

variable "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer"
  type        = string
}

variable "key_path" {
  description = "Path to the SSH private key on the local machine"
  type        = string
}

variable "bastion_public_ip" {
  description = "Public IP of the bastion host"
  type        = string
}
