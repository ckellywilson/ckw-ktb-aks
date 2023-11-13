# ckw-ktb-aks
Additional demos and resources for the Kubernetes Technical Briefing

# Create Initial Cluster (Powershell)
## Define Variables
`$AKS_RESOURCE_GROUP="k8s-tech-brief-rg"`</br>
`$LOCATION="eastus"`</br>
`$VM_SKU="Standard_D2as_v5"`</br>
`$AKS_NAME="ktb-aks"`

## Create Resource Group
`az group create --location $LOCATION --resource-group $AKS_RESOURCE_GROUP`

## Create Cluster
`az aks create --resource-group $AKS_RESOURCE_GROUP --name $AKS_NAME --generate-ssh-keys --vm-set-type VirtualMachineScaleSets --enable-cluster-autoscaler --min-count 3 --max-count 5 --load-balancer-sku standard --node-count 3 --zones 1 2 3`