# Project 01: GitHub Actions + Docker + AWS ECR + ECS

This project demonstrates a complete CI/CD pipeline for a Flask web application. The application is automatically built into a Docker image, pushed to AWS ECR, and deployed to an AWS ECS cluster running on Fargate whenever code is pushed to the `main` branch. It uses Infrastructure as Code (Terraform) for provisioning the AWS infrastructure.

## 📋 Prerequisites

Before you begin, ensure you have the following:

1.  **GitHub Account**: An account on [GitHub](https://github.com/).
2.  **AWS Account**: An active AWS account with necessary permissions to create ECS clusters, services, ECR repositories, IAM roles, and ALBs. An AWS user with `AdministratorAccess` or a custom policy with the required permissions is recommended for this setup.
3.  **AWS CLI**: Installed and configured on your local machine. You can install it [here](https://aws.amazon.com/cli/). Configure it using `aws configure`.
4.  **Terraform**: Installed on your local machine. Download it [here](https://www.terraform.io/downloads).
5.  **Docker**: Installed on your local machine (for local testing if needed). Download it [here](https://www.docker.com/get-started).
6.  **Git**: Installed on your local machine. Download it [here](https://git-scm.com/downloads).
7.  **A Forked/Cloned Repository**: Fork this repository (`vijayb-aiops/devops-cicd-projects`) or create your own, and clone it to your local environment.

## 🏗️ Step 1: Set Up AWS Infrastructure using Terraform

This project requires specific AWS resources to be created before the CI/CD pipeline can deploy the application. We'll use Terraform to manage this infrastructure.

1.  **Navigate to the Terraform Directory:**
    ```bash
    cd devops-cicd-projects/project-01-github-actions-ecs/terraform
    ```

2.  **Initialize Terraform:**
    This command downloads the necessary provider plugins.
    ```bash
    terraform init
    ```

3.  **Review the Execution Plan:**
    This command shows what resources Terraform will create, modify, or destroy.
    ```bash
    terraform plan
    ```
    Review the plan carefully. Ensure it matches the resources you expect (ECS cluster, service, task definition, ECR repo, ALB, etc.).

4.  **Apply the Configuration:**
    This command creates the resources in your AWS account. You will be prompted to confirm the action.
    ```bash
    terraform apply
    ```
    Type `yes` when prompted to confirm.

5.  **Note Important Outputs:**
    After successful application, Terraform will display outputs. Pay close attention to:
    *   `alb_dns_name`: The DNS name of the Application Load Balancer. You will access your application here.
    *   `ecs_cluster_name`: The name of the ECS cluster.
    *   `ecs_service_name`: The name of the ECS service.
    *   `ecr_repository_url`: The URL of the ECR repository where your Docker images will be stored.
    *   `task_definition_family`: The family name of the ECS task definition.
    You might need these values later for configuration or troubleshooting.

## 🔐 Step 2: Configure GitHub Secrets for AWS Authentication

GitHub Actions needs credentials to interact with your AWS account. The recommended and most secure way is using GitHub's OIDC (OpenID Connect) authentication. If you cannot set up OIDC, you can use AWS Access Keys, but this is less secure.

### Option A: Using GitHub OIDC (Recommended)

1.  **Create an IAM Role in AWS:**
    *   Go to the AWS IAM console.
    *   Click "Roles" and then "Create role".
    *   Select "Web Identity" as the trusted entity.
    *   For "Identity provider", select "Token Issuer": `https://token.actions.githubusercontent.com`.
    *   For "Audience", enter `sts:AssumeRoleWithWebIdentity`.
    *   Click "Next: Permissions".
    *   Attach policies that grant necessary permissions for ECS, ECR, and any other resources your pipeline needs (e.g., `AmazonECS_FullAccess`, `AmazonEC2ContainerRegistryFullAccess`). Be specific with permissions based on your security requirements.
    *   Click "Next: Tags" (add if needed) and then "Next: Review".
    *   Give the role a name (e.g., `GitHubActionsECSRole`) and create it.
    *   Note the **Role ARN**.

2.  **Configure the IAM Role Trust Policy (if needed):**
    The trust policy created by default for Web Identity should be sufficient, but ensure it looks similar to this, replacing `YOUR_GITHUB_ACCOUNT` and `YOUR_REPOSITORY_NAME`:
    ```json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
          },
          "Action": "sts:AssumeRoleWithWebIdentity",
          "Condition": {
            "StringEquals": {
              "token.actions.githubusercontent.com:aud": "sts:AssumeRoleWithWebIdentity",
              "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_ACCOUNT/YOUR_REPOSITORY_NAME:ref:refs/heads/main"
            }
          }
        }
      ]
    }
    ```
    Adjust the `sub` condition to match your repository and branch.

3.  **Update the GitHub Actions Workflow (`cicd.yml`):**
    In `.github/workflows/cicd.yml`, locate the `Configure AWS credentials` step. It should use the `aws-actions/configure-aws-credentials` action with the `role-to-assume` parameter set to the ARN of the role you created.
    ```yaml
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        role-to-assume: arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubActionsECSRole # <-- Replace with your role ARN
        aws-region: us-east-1 # <-- Replace with your chosen region
        role-session-name: GitHubActionsSession
    ```
    Replace `arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubActionsECSRole` with the actual ARN of the IAM role you created. Also, update the `aws-region` to match your setup.

### Option B: Using AWS Access Keys (Less Secure - Not Recommended for Production)

1.  **Create an IAM User in AWS:**
    *   Go to the AWS IAM console.
    *   Click "Users" and then "Add users".
    *   Give the user a name (e.g., `GitHubActionsUser`).
    *   Select "Attach policies directly".
    *   Attach policies that grant necessary permissions for ECS, ECR, and any other resources your pipeline needs (e.g., `AmazonECS_FullAccess`, `AmazonEC2ContainerRegistryFullAccess`). Be specific with permissions based on your security requirements.
    *   Click "Next: Tags" (add if needed) and then "Next: Review".
    *   Create the user.
    *   Go to the "Security credentials" tab for the user.
    *   Click "Create access key".
    *   Select "Application running outside AWS".
    *   Save the `Access key ID` and `Secret access key` securely.

2.  **Add Secrets to GitHub Repository:**
    *   Go to your GitHub repository settings.
    *   Click "Secrets and variables" -> "Actions".
    *   Click "New repository secret".
    *   Add the following secrets:
        *   Name: `AWS_ACCESS_KEY_ID`, Value: The Access key ID you created.
        *   Name: `AWS_SECRET_ACCESS_KEY`, Value: The Secret access key you created.
        *   Name: `AWS_DEFAULT_REGION`, Value: The AWS region where your resources are (e.g., `us-east-1`).

3.  **Update the GitHub Actions Workflow (`cicd.yml`):**
    In `.github/workflows/cicd.yml`, locate the `Configure AWS credentials` step. It should use the secrets you just created.
    ```yaml
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_DEFAULT_REGION }}
    ```

## 📝 Step 3: Update the GitHub Actions Workflow File

1.  **Locate the Workflow File:**
    Ensure the file `.github/workflows/cicd.yml` exists in your repository.

2.  **Edit `cicd.yml`:**
    Open `.github/workflows/cicd.yml` and ensure the environment variables (`env:` section) at the top match the names and details of the resources created by Terraform.
    ```yaml
    env:
      AWS_REGION: us-east-1                   # Set your AWS region - Ensure this matches your Terraform config
      ECR_REPOSITORY: your-ecr-repo-name      # Set your ECR repo name - Ensure this matches your Terraform config
      ECS_SERVICE: your-ecs-service-name      # Set your ECS service name - Ensure this matches your Terraform config
      ECS_CLUSTER: your-ecs-cluster-name      # Set your ECS cluster name - Ensure this matches your Terraform config
      ECS_TASK_DEFINITION: task-definition.json # Set your task definition path - Ensure this matches your Terraform output or how you reference it in the deploy action
    ```
    Replace `your-...` placeholders with the actual names used in your Terraform configuration and outputs. The `ECS_TASK_DEFINITION` path should point to the file containing your task definition JSON, which is typically generated by Terraform and referenced in the `amazon-ecs-render-task-definition` action.

## 🚀 Step 4: Deploy the Application

1.  **Commit and Push:**
    Ensure all your changes (Terraform files, `app.py`, `Dockerfile`, `cicd.yml`, etc.) are committed to the `main` branch of your GitHub repository.
    ```bash
    git add .
    git commit -m "Initial commit: Set up CI/CD pipeline for Flask app"
    git push origin main
    ```

2.  **Trigger the Workflow:**
    Pushing to the `main` branch will trigger the GitHub Actions workflow defined in `.github/workflows/cicd.yml`.

3.  **Monitor the Workflow:**
    Go to the "Actions" tab in your GitHub repository. You should see the workflow run. Click on it to view the logs and confirm each step (build, push, deploy) completes successfully.

4.  **Access the Application:**
    Once the workflow completes successfully, navigate to the `alb_dns_name` output from the Terraform apply step (or check the ALB in the AWS console). You should see your Flask application running (e.g., "Hello from GitHub Actions + ECS!").

## 🧪 Step 5: Local Development (Optional)

For local testing, you can use `docker-compose`:

1.  Ensure Docker is installed.
2.  Run the following command in the project root (`project-01-github-actions-ecs/`):
    ```bash
    docker-compose up --build
    ```
3.  Access the application at `http://localhost:5000`.

## 📁 Project Structure

For a detailed breakdown of the files and directories, see `project-overview.md`.

## 🚧 Troubleshooting

*   **Workflow Fails:** Check the logs in the GitHub Actions UI for specific error messages.
*   **ECS Service Not Updating:** Verify the image tag in the ECS task definition matches the one pushed to ECR. Check the ECS service logs in CloudWatch.
*   **Permission Errors:** Double-check the IAM permissions for the AWS credentials used by GitHub Actions (OIDC role or Access Keys).
*   **Terraform Errors:** Review the Terraform plan/apply output for specific error messages. Ensure your AWS credentials have sufficient permissions to create the defined resources.

## 🏗️ Infrastructure Details (Terraform)

The required AWS infrastructure (ECS Cluster, Task Definition, Service, ECR Repository, ALB, Security Groups, etc.) is defined in the `terraform/` directory. Applying this configuration with `terraform apply` is a prerequisite for the CI/CD pipeline to function.
