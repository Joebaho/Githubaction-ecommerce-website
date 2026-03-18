# E-Commerce Website on AWS EKS with GitHub Actions

This project deploys a static e-commerce website to Amazon EKS using Terraform, Docker, Amazon ECR, Kubernetes, and GitHub Actions.

## What the project does

- Provisions AWS networking, EKS, and an ECR repository with Terraform
- Builds the website image with Docker
- Pushes the image to Amazon ECR
- Deploys the image to EKS with Kubernetes manifests
- Runs deployment automatically from GitHub Actions

## Repository structure

```text
.
├── .github/workflows/
│   ├── deploy.yml
│   └── destroy.yml
├── k8s/
│   ├── namespace.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── scripts/
│   ├── configure_kubectl.sh
│   └── install_tools.sh
├── site/
│   └── index.html
├── terraform/
│   ├── backend.tf
│   ├── eks.tf
│   ├── iam.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── variables.tf
│   └── vpc.tf
└── Dockerfile
```

## Required GitHub secrets

Add these repository secrets before running the workflows:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

The IAM user or role behind those credentials needs permission to manage EKS, EC2, IAM, VPC, ECR, and related resources.
It also needs permission to manage the Terraform state bucket and DynamoDB lock table used by GitHub Actions.

## Deployment flow

The deploy workflow runs on pushes to `main` and on manual dispatch.

1. Configure AWS credentials
2. Create or reuse an S3 bucket and DynamoDB table for Terraform state
3. Run `terraform init` and `terraform apply` against that shared backend
4. Read the ECR repository URL from Terraform outputs
5. Build and push the Docker image to ECR
6. Update kubeconfig for the EKS cluster
7. Apply the Kubernetes manifests and wait for rollout

## Local usage

```bash
terraform -chdir=terraform init
terraform -chdir=terraform apply

docker build -t ecommerce-local .

aws eks update-kubeconfig --region us-west-2 --name ecommerce-eks
kubectl apply -f k8s/namespace.yaml
sed "s|IMAGE_URI|<your-ecr-image-uri>|g" k8s/deployment.yaml | kubectl apply -f -
kubectl apply -f k8s/service.yaml
```

To destroy the infrastructure manually:

```bash
terraform -chdir=terraform destroy
```

## Notes

- The default AWS region is `us-west-2`
- The EKS cluster name is `ecommerce-eks`
- The website content served by Nginx is in `site/index.html`
- GitHub Actions stores Terraform state in S3 and uses DynamoDB for state locking
