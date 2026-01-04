output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.main.name
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_url" {
  description = "Application Load Balancer URL"
  value       = "http://${aws_lb.main.dns_name}"
}

output "ecr_api_gateway_repository_url" {
  description = "ECR repository URL for API Gateway"
  value       = aws_ecr_repository.api_gateway.repository_url
}

output "ecr_auth_service_repository_url" {
  description = "ECR repository URL for Auth Service"
  value       = aws_ecr_repository.auth_service.repository_url
}

output "ecr_user_service_repository_url" {
  description = "ECR repository URL for User Service"
  value       = aws_ecr_repository.user_service.repository_url
}

output "ecr_frontend_repository_url" {
  description = "ECR repository URL for Frontend"
  value       = aws_ecr_repository.frontend.repository_url
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.appvida.name
}
