# Project 01: GitHub Actions + Docker + AWS ECR + ECS

## 🎯 Problem Solved
Manual deployment of applications to AWS ECS was time-consuming, error-prone, and slow. It required multiple manual steps (build, tag, push, update service) which led to inconsistencies and delays in getting code to production.

## 🛠️ Tools Used
- GitHub Actions
- Docker
- AWS ECR (Elastic Container Registry)
- AWS ECS (Elastic Container Service)
- AWS CLI
- Terraform (for infrastructure setup)

## 📊 Situation
- Need to deploy a Flask web application.
- Current process involves manual Docker builds and ECS service updates.
- Deployment takes 30+ minutes and often breaks due to human error.

## 🎯 Task
Build an automated CI/CD pipeline that:
1. Listens for code changes in a GitHub repository.
2. Automatically builds a Docker image.
3. Pushes the image to AWS ECR.
4. Deploys the new image to an existing ECS service.
5. Provides notifications on success/failure.

## ⚡ Action
1. **Set up Infrastructure**: Used Terraform to provision ECS cluster, task definition, service, and ECR repository.
2. **Containerize Application**: Created a `Dockerfile` for the Flask app.
3. **Configure GitHub Actions**: Wrote a workflow (`cicd.yml`) that:
   - Triggers on push to `main` branch.
   - Sets up AWS credentials using GitHub Secrets.
   - Builds the Docker image.
   - Tags the image with the commit hash.
   - Pushes the image to ECR.
   - Updates the ECS service with the new image tag.
4. **Add Health Checks**: Included a script to verify the application is running correctly after deployment.
5. **Document Process**: Created detailed README and architecture diagrams.

## 🏆 Results
- **Deployment Time**: Reduced from 30+ minutes to 5-10 minutes.
- **Error Rate**: Reduced to near zero by eliminating manual steps.
- **Consistency**: Deployments are now identical every time.
- **Reliability**: Automated rollback can be added if health checks fail.
