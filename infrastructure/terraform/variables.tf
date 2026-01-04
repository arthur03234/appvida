variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "sa-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "appvida"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["sa-east-1a", "sa-east-1b", "sa-east-1c"]
}

variable "mongodb_uri" {
  description = "MongoDB Atlas connection string"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT secret key"
  type        = string
  sensitive   = true
}

variable "api_gateway_cpu" {
  description = "API Gateway CPU units"
  type        = number
  default     = 256
}

variable "api_gateway_memory" {
  description = "API Gateway memory in MB"
  type        = number
  default     = 512
}

variable "auth_service_cpu" {
  description = "Auth Service CPU units"
  type        = number
  default     = 256
}

variable "auth_service_memory" {
  description = "Auth Service memory in MB"
  type        = number
  default     = 512
}

variable "user_service_cpu" {
  description = "User Service CPU units"
  type        = number
  default     = 256
}

variable "user_service_memory" {
  description = "User Service memory in MB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 2
}
