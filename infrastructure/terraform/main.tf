terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "appvida-terraform-state"
    key    = "terraform.tfstate"
    region = "sa-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "AppVida"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
