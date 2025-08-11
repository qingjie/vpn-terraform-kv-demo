#!/bin/bash
ENVIRONMENT="dev"
REGION="eastus"
STORAGE_ACCOUNT="tfstate${ENVIRONMENT}${REGION}"
echo "Ping test..."
ping -c 3 ${STORAGE_ACCOUNT}.blob.core.windows.net
echo "DNS lookup..."
dig +short ${STORAGE_ACCOUNT}.blob.core.windows.net
echo "Azure CLI storage check..."
az storage account show -n ${STORAGE_ACCOUNT} -g rg-terraform-backend-${REGION} || true
