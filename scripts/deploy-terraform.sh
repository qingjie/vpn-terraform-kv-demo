#!/bin/bash
set -e
if [ -z "$1" ]; then
  echo "Usage: $0 <environment: dev|qa|prod>"
  exit 1
fi
ENV=$1
REGION="eastus"
echo "Deploying Terraform for $ENV in $REGION"
export ARM_SUBSCRIPTION_ID="<your-subscription-id>"
export ARM_TENANT_ID="<your-tenant-id>"
export ARM_CLIENT_ID="<your-client-id>"
export ARM_CLIENT_SECRET="<your-client-secret>"
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
az account set --subscription $ARM_SUBSCRIPTION_ID
cd terraform
terraform init -backend-config="storage_account_name=tfstate${ENV}${REGION}" -backend-config="key=${ENV}.terraform.tfstate"
terraform apply -auto-approve -var-file="../envs/${ENV}.tfvars"
