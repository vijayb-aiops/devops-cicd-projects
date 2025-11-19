# Challenges Faced: GitHub Actions + Docker + AWS ECR + ECS

## Challenge 1: Configuring AWS Credentials in GitHub Actions

*   **Problem**: How to securely grant GitHub Actions the necessary permissions to interact with AWS services (ECR, ECS) without exposing long-term credentials?
*   **Solution**: Utilized GitHub's built-in OIDC (OpenID Connect) authentication for AWS. This involves creating an IAM role in AWS that trusts the GitHub Actions OIDC provider, and configuring the GitHub Actions workflow to assume this role. This avoids the need to store long-lived AWS access keys in GitHub Secrets. Alternatively, if OIDC is not configured, the traditional method involves storing `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as secrets in the GitHub repository settings and configuring them in the workflow using the `aws-actions/configure-aws-credentials` action.
*   **Details**: The workflow uses the `aws-actions/configure-aws-credentials` action, which requires the appropriate AWS credentials to be available (either via OIDC or secrets like `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`). The IAM role associated with these credentials must have sufficient permissions for ECR (e.g., `ecr:GetAuthorizationToken`, `ecr:BatchCheckLayerAvailability`, `ecr:BatchGetImage`, `ecr:CompleteLayerUpload`, `ecr:GetDownloadUrlForLayer`, `ecr:InitiateLayerUpload`, `ecr:PutImage`, `ecr:UploadLayerPart`) and ECS (e.g., `ecs:RegisterTaskDefinition`, `ecs:UpdateService`, `iam:PassRole` for the task execution role).

## Challenge 2: ECS Service Not Updating Correctly

*   **Problem**: After pushing a new Docker image to ECR, the ECS service might not automatically pick up the new image version, or the deployment might fail.
*   **Solution**: Ensure the GitHub Actions workflow correctly updates the ECS task definition JSON file (or uses `amazon-ecs-render-task-definition`) to reference the new image tag (e.g., the commit SHA). Then, explicitly call `aws ecs update-service --force-new-deployment` (or use the `amazon-ecs-deploy-task-definition` action with `wait-for-service-stability: true`) to instruct ECS to start new tasks with the updated definition and stop the old ones. The `wait-for-service-stability` option ensures the deployment step waits for the service to reach a stable state before proceeding.
*   **Details**: The task definition JSON used by ECS must contain the correct image URI. The deployment step in the GitHub Actions workflow is responsible for updating this definition and triggering the service update.

## Challenge 3: Initial Infrastructure Setup (ECS Cluster, Service, ALB, Security Groups)

*   **Problem**: Before the CI/CD pipeline can deploy, the underlying AWS infrastructure (ECS cluster, task definition, service, ALB, VPC, subnets, security groups) must exist.
*   **Solution**: Use Infrastructure as Code (IaC) tools like Terraform or AWS CloudFormation. The `terraform/` directory contains the necessary configuration files (`main.tf`, `variables.tf`, etc.) to provision this infrastructure declaratively. This infrastructure must be deployed *before* the CI/CD pipeline can be used for the first time.
*   **Details**: The Terraform configuration defines resources like `aws_ecs_cluster`, `aws_ecs_service`, `aws_lb` (Application Load Balancer), `aws_security_group`, etc. The GitHub Actions workflow updates an *existing* ECS service, it does not create the cluster or service from scratch during the pipeline run (unless the workflow includes a step to apply Terraform changes, which is less common for simple app deployments).
