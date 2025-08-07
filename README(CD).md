# Kubernetes and Terraform Deployment Files

This directory contains all the necessary files for deploying your web application to an EKS cluster.

## Contents

1. **Kubernetes Manifests** (in `/k8s` directory)
   - `deployment.yaml` - Deployment configuration for your web application
   - `service.yaml` - Service configuration to expose your application via LoadBalancer

2. **Terraform Code** (in `/terraform` directory)
   - `main.tf` - Terraform configuration to provision an EKS cluster in us-east-1

3. **Jenkins Pipeline** (in `/jenkins` directory)
   - `Jenkinsfile` - Complete CI/CD pipeline including deployment to Kubernetes

## Usage Instructions

### Kubernetes Deployment

The Kubernetes manifests are ready to use. The deployment manifest uses the environment variable `${IMAGE_TAG}` which will be replaced by the Jenkins pipeline during deployment.

### Terraform EKS Provisioning

To provision the EKS cluster:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Jenkins Pipeline

The Jenkinsfile is configured to:
1. Build and test your application
2. Create a Docker image and push it to DockerHub
3. Deploy the application to your EKS cluster

Make sure to configure the following Jenkins credentials:
- `aws-cred` - AWS credentials for EKS access
- `docker-cred` - DockerHub credentials for image pushing

## Notes

- The EKS cluster is named "my-web-cluster" in the us-east-1 region
- The web application is exposed on port 8080 internally and port 80 externally
- The deployment includes health checks to ensure application availability

## Architecture Diagram

- ### High-Level Overview:
![image](https://github.com/user-attachments/assets/c7d2d2bf-5318-463e-8d15-36444ca49fd7)

- Detailed Implementation:

![image](https://github.com/user-attachments/assets/e4588cec-7d93-40c8-a2a2-f31d1c9f96c2)


The diagram above illustrates the AWS infrastructure and Kubernetes resources used to deploy our web application.
