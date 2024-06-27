#!/bin/bash

# Login to Azure
echo "Logging in to Azure..."
az login --use-device-code

# Variables
# Get the Azure AD signed-in user ID
echo "Getting the Azure AD signed-id user ID..."
adminUserId=$(az ad signed-in-user show --query "id" --output tsv)
echo "adminUserId: $adminUserId"

prefix=""
echo 'Enter a prefix for the resources using your initials and 2 digits: '
read prefix
echo "prefix: $prefix"

# Generate SSH key
echo "Generating SSH key..."
ssh-keygen -t rsa -b 4096 -f ~/.ssh/${prefix}-ktb-mod4-sh -N ""

keyData=$(cat ~/.ssh/${prefix}-ktb-mod4-sh.pub)
location="centralus"
deploymentName="${prefix}-ktb-mod4"
resourceGroupName="${prefix}-ktb-mod4-rg"

# Deploy AKS cluster using Bicep template
az deployment sub create --name $deploymentName \
    --location $location \
    --parameters ./main.bicepparam \
    --parameters location="$location" \
    --parameters resourceGroupName="$resourceGroupName" \
    --parameters keyData="$keyData" \
    --parameters adminUserId="$adminUserId" \
    --template-file ./main.bicep

# Get ACR name
echo "Getting ACR name..."
acr_name=$(az deployment sub show --name $deploymentName --query "properties.outputs.acrName.value" --output tsv)

# Get AKS name
echo "Getting AKS name..."
aks_name=$(az deployment sub show --name $deploymentName --query "properties.outputs.aksName.value" --output tsv)

# Get AKS resource group
echo "Getting AKS resource group..."
aks_rg=$(az deployment sub show --name $deploymentName --query "properties.outputs.resourceGroupName.value" --output tsv)

# Attach ACR to AKS
echo "Attaching ACR to AKS..."
az aks update --name $aks_name --resource-group $aks_rg --attach-acr $acr_name
