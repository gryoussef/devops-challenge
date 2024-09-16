terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
   backend "s3" {
    bucket         = "k3s-terraform-state-bucket"
    region         = "eu-west-3"
    encrypt        = true
  }
}