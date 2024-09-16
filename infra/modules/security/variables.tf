variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "bastion_ingress_cidr" {
  description = "CIDR block for SSH access to the bastion host"
  type        = string
  default     = "0.0.0.0/0"
}