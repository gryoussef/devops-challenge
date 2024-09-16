variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "k3s-cluster"
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "k3s"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of AZs to use for the subnets"
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "bastion_ingress_cidr" {
  description = "CIDR block for SSH access to the bastion host"
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_name" {
  description = "The name of the key pair to use for EC2 instances"
  type        = string
  default     = "k3s-key"
}

variable "bastion_instance_type" {
  description = "The instance type for the bastion host"
  type        = string
  default     = "t2.micro"
}

variable "environment" {
  description = "The environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "master_instance_type" {
  description = "Instance type for Kubernetes master nodes"
  type        = string
  default     = "t3.small"
}

variable "worker_instance_type" {
  description = "Instance type for Kubernetes worker nodes"
  type        = string
  default     = "t3.small"
}

variable "master_count" {
  description = "Number of Kubernetes master nodes"
  type        = number
  default     = 3
}

variable "min_worker_count" {
  description = "Minimum number of Kubernetes worker nodes"
  type        = number
  default     = 1
}

variable "max_worker_count" {
  description = "Maximum number of Kubernetes worker nodes"
  type        = number
  default     = 3
}

variable "desired_worker_count" {
  description = "Desired number of Kubernetes worker nodes"
  type        = number
  default     = 3
}

variable "domain_name" {
  description = "The domain name to use for the cluster"
  type        = string
  default     = "eljirari.me"
}

variable "hosted_zone_id" {
  description = "The ID of the Route 53 hosted zone for the domain"
  type        = string
  default     = "Z03797933AKI0ZECD39VO"
}

