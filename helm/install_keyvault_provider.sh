#!/bin/bash

# Add the required Helm repositories
helm repo add csi-secrets-store-provider-azure https://azure.github.io/secrets-store-csi-driver-provider-azure/charts
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm repo update

# Delete existing CSIDriver if it exists (this will allow us to reinstall with proper Helm metadata)
kubectl delete csidriver secrets-store.csi.k8s.io --ignore-not-found

# Install the Secrets Store CSI Driver
helm upgrade --install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver \
    --namespace kube-system \
    --create-namespace \
    --set syncSecret.enabled=true \
    --wait

# Install the Azure Key Vault Provider
helm upgrade --install csi-secrets-store-provider-azure csi-secrets-store-provider-azure/csi-secrets-store-provider-azure \
    --namespace kube-system \
    --set "linux.enabled=true" \
    --wait

# Verify the installation
echo "Waiting for the Key Vault provider pods to be ready..."
kubectl wait --for=condition=ready pod -l app=csi-secrets-store-provider-azure --namespace kube-system --timeout=60s

echo "Key Vault CSI Provider installation completed"
