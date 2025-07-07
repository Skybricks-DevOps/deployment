#!/bin/bash

# 📌 Paramètres personnalisés
LOCATION="westeurope"
RESOURCE_GROUP="rg-devops-cicd"
KEYVAULT_NAME="kv-devops-cicd-laeti"
SECRET_NAME="POSTGRES-CONN-STRING"
SECRET_VALUE="postgresql://adminuser@pg-prod:SuperSecure123@pg-prod.postgres.database.azure.com:5432/employeesdb"
SP_CLIENT_ID="a090ce38-1d69-4227-b2d3-f69c2ab9239c"

echo "📁 Création du groupe de ressources (si nécessaire)..."
az group create --name $RESOURCE_GROUP --location $LOCATION

echo "🧹 Purge éventuelle du Key Vault existant (si soft-delete actif)..."
az keyvault purge --name $KEYVAULT_NAME 2>/dev/null || echo "Aucun Vault à purger"

echo "🔧 Création du Key Vault sans RBAC..."
az keyvault create \
  --name $KEYVAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku standard

echo "🔐 Ajout du secret PostgreSQL..."
az keyvault secret set \
  --vault-name $KEYVAULT_NAME \
  --name $SECRET_NAME \
  --value "$SECRET_VALUE"

echo "👤 Attribution des droits au Service Principal GitHub Actions..."
SP_OBJECT_ID="2b6751f8-4ba8-4990-b9de-fbe582c82151"

if [ -z "$SP_OBJECT_ID" ]; then
  echo "❌ Erreur : SP_OBJECT_ID vide. Vérifie le clientId."
  exit 1
fi

az keyvault set-policy \
  --name $KEYVAULT_NAME \
  --object-id $SP_OBJECT_ID \
  --secret-permissions get list

echo "✅ Liste des secrets dans le Key Vault $KEYVAULT_NAME :"
az keyvault secret list --vault-name $KEYVAULT_NAME -o table

echo "🎉 Key Vault prêt et intégré avec GitHub Actions !"
