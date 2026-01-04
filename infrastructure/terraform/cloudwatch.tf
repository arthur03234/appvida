# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "appvida" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 30

  tags = {
    Name = "${var.project_name}-logs"
  }
}

# CloudWatch Log Streams
resource "aws_cloudwatch_log_stream" "api_gateway" {
  name           = "api-gateway"
  log_group_name = aws_cloudwatch_log_group.appvida.name
}

resource "aws_cloudwatch_log_stream" "auth_service" {
  name           = "auth-service"
  log_group_name = aws_cloudwatch_log_group.appvida.name
}

resource "aws_cloudwatch_log_stream" "user_service" {
  name           = "user-service"
  log_group_name = aws_cloudwatch_log_group.appvida.name
}

resource "aws_cloudwatch_log_stream" "frontend" {
  name           = "frontend"
  log_group_name = aws_cloudwatch_log_group.appvida.name
}
