# Project Structure: Module 1, Project 1 - GitHub Actions + Docker + AWS ECR + ECS

This document outlines the intended folder and file structure for the project.

```
project-01-github-actions-ecs/
├── README.md                           ← Detailed setup and deployment guide
├── project-overview.md                 ← STAR format summary
├── scripts/                            ← Automation scripts
│   ├── build.sh                        ← Script to build Docker image
│   ├── push-ecr.sh                     ← Script to push to AWS ECR
│   ├── deploy-ecs.sh                   ← Script to update ECS service
│   └── health-check.sh                 ← Script to verify deployment
├── docs/                               ← Detailed documentation
│   ├── architecture.md                 ← Mermaid diagram + explanation
│   ├── challenges.md                   ← Problems faced + solutions
│   └── metrics.md                      ← Before/after metrics
├── terraform/                          ← Infrastructure as Code
│   ├── main.tf                         ← ECS cluster, service, task def
│   ├── variables.tf                    ← Input variables
│   ├── outputs.tf                      ← Exported values (e.g., ALB URL)
│   └── ecr.tf                          ← ECR repository definition
├── app/                                ← Web application source code
│   ├── app.py                          ← Flask application
│   ├── requirements.txt                ← Python dependencies
│   └── Dockerfile                      ← Instructions to build Docker image
├── .github/workflows/                  ← GitHub Actions CI/CD
│   └── cicd.yml                        ← Workflow definition
├── k8s-manifests/                      ← (Optional, for comparison) K8s configs
├── screenshots/                        ← Screenshots of deployment, logs, etc.
└── docker-compose.yml                  ← (Optional) Local development setup
```