# Detailed Kubernetes Setup and Application Deployment

## K3s Cluster Configuration

The K3s cluster is set up using cloud-init scripts on EC2 instances. Here's a snippet of the master node configuration:

```bash
#!/bin/bash
TOKEN="${k3s_token}"
curl -sfL https://get.k3s.io | sh -s - server \
  --token="$TOKEN" \
  --tls-san="${nlb_dns_name}" \
  --cluster-init
```

Key features:
- `--tls-san`: Adds the NLB DNS name to the TLS certificate's Subject Alternative Names
- `--cluster-init`: Initializes the first server node in the cluster

Worker nodes join the cluster using a similar script, pointing to the NLB DNS name:

```bash
#!/bin/bash
TOKEN="${k3s_token}"
K3S_URL="https://${nlb_dns_name}:6443"
curl -sfL https://get.k3s.io | K3S_URL="$K3S_URL" K3S_TOKEN="$TOKEN" sh -
```

## Flux CD Setup

Flux CD is installed on the cluster to manage GitOps-based deployments. The setup is defined in Kubernetes manifests:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: flux-system
  namespace: flux-system
spec:
  interval: 1m0s
  ref:
    branch: main
  secretRef:
    name: flux-system
  url: ssh://git@github.com/gryoussef/devops-challenge

---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: flux-system
  namespace: flux-system
spec:
  interval: 10m0s
  path: ./clusters/k3s
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
```

This configuration sets up Flux to monitor the GitHub repository and apply changes to the cluster.

## Application Deployment

The Bird Application is deployed using Helm charts, which are managed by Flux CD. Here's a snippet of the HelmRelease custom resource:

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: bird-app
  namespace: default
spec:
  interval: 5m
  chart:
    spec:
      chart: ./deploy/helm
      sourceRef:
        kind: GitRepository
        name: flux-system
        namespace: flux-system
  values:
    replicaCount: 2
    birdApi:
      image: "gryoussef/bird-api:latest"
      port: 4201
    birdImageApi:
      image: "gryoussef/bird-image-api:latest"
      port: 4200
```

This configuration deploys the Bird Application using the Helm chart located in the `./deploy/helm` directory of the repository.

## Ingress Configuration

Traefik is used as the Ingress controller, configured to work with the ALB:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: bird-app-ingress
  annotations:
    kubernetes.io/ingress.class: traefik
spec:
  rules:
    - http:
        paths:
          - path: /bird
            pathType: Prefix
            backend:
              service:
                name: bird-api
                port: 
                  number: 4201
          - path: /bird-image
            pathType: Prefix
            backend:
              service:
                name: bird-image-api
                port:
                  number: 4200
```

This Ingress resource defines how external traffic is routed to the Bird Application services.
