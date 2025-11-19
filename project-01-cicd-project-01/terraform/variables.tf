variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "flask-app-repo"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "flask-app-cluster"
}

variable "ecs_task_family" {
  description = "Family name for the ECS task definition"
  type        = string
  default     = "flask-app-task"
}

variable "task_cpu" {
  description = "CPU units for the task"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory for the task"
  type        = number
  default     = 512
}