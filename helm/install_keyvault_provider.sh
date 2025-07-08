#!/bin/bash

# Add the Helm repo for CSI driver
helm repo add csi-secrets-store-provider-azure https://azure.github.io/secrets-store-csi-driver-provider-azure/charts
helm repo update

# Install the Azure Key Vault Provider
helm install csi csi-secrets-store-provider-azure/csi-secrets-store-provider-azure --namespace kube-system

# Install the Secrets Store CSI Driver
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --namespace kube-system \
  --set syncSecret.enabled=true
