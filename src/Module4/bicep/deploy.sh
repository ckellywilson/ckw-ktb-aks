#!/bin/bash

# Login to Azure
echo "Logging in to Azure..."
az login --use-device-code

# Generate SSH key
echo "Generating SSH key..."
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ktb-mod4-sh -N ""

# Variables
keyData=$(cat ~/.ssh/ktb-sh.pub)
location="eastus"
deploymentName="ktb-mod4"


# Deploy AKS cluster using Bicep template
az deployment sub create --name $deploymentName --location $location --parameters ./main.bicepparam --parameters keyData="$keyData"