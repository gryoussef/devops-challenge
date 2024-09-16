# Bird Application

## Overview

The Bird Application is a microservices-based system that provides information about birds and their images. It consists of two Go-based APIs:

1. Bird API (Port 4201): Provides bird information
2. Bird Image API (Port 4200): Fetches images of birds based on their names

The Bird API depends on the Bird Image API to retrieve bird images.

## Project Structure

```
bird-application/
│
├── bird/                 # Bird API
│   ├── Dockerfile
│   ├── main.go
│   └── go.mod
│
├── birdImage/            # Bird Image API
│   ├── Dockerfile
│   ├── main.go
│   └── go.mod
│
└── README.md
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

# Challenge

How to:
- fork the repository
- work on the challenges
- share your repository link with the recruitment team

Here are the challenges:
- [x] Install and run the app
- [x] Dockerize it (create dockerfile for each API)
- [x] Create an infra on AWS (VPC, SG, instances) using IaC
- [x] Install a small version of kubernetes on the instances (no EKS)
- [ ] Build the manifests to run the 2 APIs on k8s
- [ ] Bonus points: observability, helm, scaling

Rules:
- Use security / container / k8s / cloud best practices
- Change in the source code is possible

Evaluation criterias:
- best practices
- code organization
- clarity & readability