Sure, here is the formatted documentation:

# Bird Application

## Overview

The Bird Application is a microservices-based system that provides information about birds and their images. It consists of two Go-based APIs:

1. **Bird API (Port 4201)**: Provides bird information
2. **Bird Image API (Port 4200)**: Fetches images of birds based on their names

The Bird API depends on the Bird Image API to retrieve bird images.

## Project Structure

```
.
├── bird/                 # Bird API source code
├── birdImage/            # Bird Image API source code
├── clusters/             # Flux CD configuration
├── deploy/               # Helm charts for application deployment
├── infra/                # Terraform code for AWS infrastructure
└── .github/workflows/    # GitHub Actions CI/CD pipelines
```

## Prerequisites

- Go 1.22 or later
- Docker

## Local Development

### Running the Bird Image API

```bash
cd birdImage
go build -o getBirdImage
./getBirdImage
```

The Bird Image API will be available at `http://localhost:4200`.

### Running the Bird API

```bash
cd bird
go build -o getBird
./getBird
```

The Bird API will be available at `http://localhost:4201`.

## Docker Deployment

### Building Docker Images

1. Build the Bird Image API:
   ```bash
   cd birdImage
   docker build -t bird-image-api .
   ```

2. Build the Bird API:
   ```bash
   cd bird
   docker build -t bird-api .
   ```

### Creating a Docker Network

Create a bridge network for the APIs to communicate:

```bash
docker network create bird-network --driver bridge
```

### Running Docker Containers

1. Run the Bird Image API:
   ```bash
   docker run -d --name bird-image-api --network bird-network -p 4200:4200 bird-image-api
   ```

2. Run the Bird API:
   ```bash
   docker run -d --name bird-api --network bird-network -p 4201:4201 -e BIRD_IMAGE_API_HOST=bird-image-api bird-api
   ```

## Usage

### Bird Image API

Fetch a bird image:
```
GET http://localhost:4200/?birdName=sparrow
```

### Bird API

Get random bird information:
```
GET http://localhost:4201/
```

## Environment Variables

- `BIRD_IMAGE_API_HOST`: Hostname of the Bird Image API (default: "bird-image-api")
- `BIRD_IMAGE_API_PORT`: Port of the Bird Image API (default: 4200)

## Security Considerations

- Both APIs run as non-root users within their containers.
- Distroless base images are used to minimize the attack surface.

## Infrastructure Setup

We use Terraform to set up the AWS infrastructure. Key features:

- Multi-AZ VPC setup for high availability
- Bastion host for secure cluster acces
- Auto Scaling Groups for K3s workers
- NLB for K3s API access, ALB for application traffic
- SSL/TLS termination at ALB using ACM certificates
- AWS Secrets Manager for K3s token

To set up the infrastructure:

```bash
cd infra
terraform init
terraform apply
```

## HA K3s Cluster Setup

Our HA K3s cluster is set up with:

- 3 master nodes for high availability
- 3+ worker nodes that auto-scale based on demand
- NLB for distributing traffic to master nodes
- ALB for routing external traffic to worker nodes and SSL/TLS integration, ALB is fronted by traefik as ingress controller.
- TLS encryption for all cluster communication

K3s is installed on EC2 instances using userdata scripts. Masters form a cluster with a shared token, and workers join automatically.

## Application Deployment

We use GitOps with Flux CD for deploying the Bird Application:

- Helm charts in `deploy/helm/` define the Kubernetes resources
- Flux CD configurations in `clusters/k3s/apps/` manage the deployment
- GitHub Actions build and push Docker images on code changes
- Flux CD automatically syncs these changes to the cluster

Scalability is handled through:

- Horizontal Pod Autoscaler (HPA) for the application pods
- Auto Scaling Groups for the EC2 instances

## Getting Started

1. Clone the repository
2. Set up AWS credentials
3. Run Terraform to create the infrastructure
4. Install Flux CD on the cluster
5. Push changes to the main branch to trigger deployments

## Monitoring and Observability

We plan to set up:

- Prometheus for metrics collection
- Grafana for dashboards and visualization
- Loki for log aggregation

## Security

- Least privilege IAM roles
- Security groups restricting access
- Encryption at rest and in transit
- Secrets managed securely in AWS Secrets Manager

## Future Improvements

- Implement full observability stack
- Add automated testing in the CI pipeline
- Explore canary deployments

# Challenge

## How to:

- Fork the repository
- Work on the challenges
- Share your repository link with the recruitment team

## Challenges:

- [x] Install and run the app
- [x] Dockerize it (create Dockerfile for each API)
- [x] Create an infra on AWS (VPC, SG, instances) using IaC
- [x] Install a small version of Kubernetes on the instances (no EKS)
- [x] Build the manifests to run the 2 APIs on k8s
- [x] Bonus points: observability, Helm, scaling

## Rules:

- Use security / container / k8s / cloud best practices
- Change in the source code is possible

## Evaluation Criteria:

- Best practices
- Code organization
- Clarity & readability