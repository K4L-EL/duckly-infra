#!/usr/bin/env bash
set -euo pipefail

# Bootstrap script: creates the Azure resources needed for Terraform remote state.
# Run this ONCE before your first `terraform init`.
#
# Prerequisites:
#   - Azure CLI installed and logged in (`az login`)
#   - Correct subscription selected

RESOURCE_GROUP="duckly-tfstate-rg"
STORAGE_ACCOUNT="ducklytfstate"
CONTAINER="tfstate"
LOCATION="uksouth"

echo "Creating resource group for Terraform state..."
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

echo "Creating storage account..."
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --encryption-services blob \
  --output none

echo "Fetching storage account key..."
ACCOUNT_KEY=$(az storage account keys list \
  --resource-group "$RESOURCE_GROUP" \
  --account-name "$STORAGE_ACCOUNT" \
  --query '[0].value' \
  --output tsv)

echo "Creating blob container..."
az storage container create \
  --name "$CONTAINER" \
  --account-name "$STORAGE_ACCOUNT" \
  --account-key "$ACCOUNT_KEY" \
  --output none

echo ""
echo "Bootstrap complete. You can now run:"
echo "  cd terraform"
echo "  cp terraform.tfvars.example terraform.tfvars"
echo "  # Edit terraform.tfvars with your secrets"
echo "  terraform init"
echo "  terraform plan"
echo "  terraform apply"
