variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the bastion host in"
  type        = string
}

variable "security_group_id" {
  description = "The ID of the security group for the bastion host"
  type        = string
}

variable "key_name" {
  description = "The name of the key pair to use for the bastion host"
  type        = string
}

variable "instance_type" {
  description = "The instance type of the bastion host"
  type        = string
  default     = "t2.micro"
}

variable "tags" {
  description = "Additional tags for the bastion host"
  type        = map(string)
  default     = {}
}

variable "key_path" {
  description = "Path to the SSH private key on the local machine"
  type        = string
}