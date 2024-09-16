variable "domain_name" {
  description = "The domain name to use for the cluster"
  type        = string
}

variable "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  type        = string
}

variable "alb_zone_id" {
  description = "The zone ID of the Application Load Balancer"
  type        = string
}