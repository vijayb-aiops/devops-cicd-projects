# Define required providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Create an ECR repository
resource "aws_ecr_repository" "flask_app_repo" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Create an ECS cluster
resource "aws_ecs_cluster" "flask_app_cluster" {
  name = var.ecs_cluster_name
}

# Create an ECS task definition
resource "aws_ecs_task_definition" "flask_app_task" {
  family                   = var.ecs_task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "flask-app"
      image = "${aws_ecr_repository.flask_app_repo.repository_url}:latest" # This will be replaced by the pipeline

      portMappings = [
        {
          containerPort = 5000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# (Additional resources like ALB, Security Groups, IAM roles, etc., would go here)

# Output the ECR repository URL
output "ecr_repository_url" {
  value = aws_ecr_repository.flask_app_repo.repository_url
}

# Output the ECS cluster name
output "ecs_cluster_name" {
  value = aws_ecs_cluster.flask_app_cluster.name
}