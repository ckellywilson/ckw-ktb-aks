# Lab Module 6: Advanced Kubernetes Topics - Part 1

This repository contains the labs for Module 6 of the WorkshopPLUS - K8s Technical Brief with Labs course.

## Exercise: Using Secrets Stored in Azure Key Vault

Use Azure Key Vault to load data into K8s secrets

### Task 1 - Enable Key Vault Addon in AKS and create Key Vault

__Step 2__ Enable Key Vault Addon in AKS
</br>
`az aks enable-addons --addons azure-keyvault-secrets-provider --name myAKSCluster --resource-group myResourceGroup`

