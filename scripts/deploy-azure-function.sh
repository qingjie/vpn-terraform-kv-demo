#!/bin/bash
set -e
if [ -z "$1" ]; then
  echo "Usage: $0 <environment>"
  exit 1
fi
ENV=$1
RESOURCE_GROUP="rg-func-${ENV}"
FUNC_NAME="acr-trigger-func-${ENV}"
LOCATION="eastus"
az group create -n $RESOURCE_GROUP -l $LOCATION
STORAGE_NAME="funcstorage${ENV}eastus"
az storage account create -n $STORAGE_NAME -g $RESOURCE_GROUP -l $LOCATION --sku Standard_LRS
az functionapp create -g $RESOURCE_GROUP -n $FUNC_NAME --storage-account $STORAGE_NAME --runtime python --functions-version 3 --os-type Linux --consumption-plan-location $LOCATION
# assign system-assigned identity
az functionapp identity assign -g $RESOURCE_GROUP -n $FUNC_NAME
echo "Deploying function code (requires func CLI installed)"
pushd ../azure-function/ACRWebhookTrigger
func azure functionapp publish $FUNC_NAME --python
popd
echo "Remember to grant the function app's principal access to Key Vault secrets."
