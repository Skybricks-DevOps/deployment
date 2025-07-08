#!/bin/bash

# Add the ingress-nginx repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Create namespace for ingress-nginx
kubectl create namespace ingress-nginx --dry-run=client -o yaml | kubectl apply -f -

# Install the nginx-ingress controller
helm upgrade --install nginx-controller ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.service.type=LoadBalancer \
  --set controller.publishService.enabled=true \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-dns-label-name"="devops-cicd"
  
echo "Waiting for the nginx-controller to be ready"
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s
echo "nginx-controller is ready"

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
helm upgrade --install nginx-ingress "$SCRIPT_DIR/ingress"
