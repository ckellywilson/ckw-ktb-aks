# variables
region="eastus"
domain="ckwilson4gmail.onmicrosoft.com"
RG_NAME="ktb-aks-module6-rg"
AKS_CLUSTER_NAME="ktb-aks-module6"
deployment_name="ktb-aks-module6-deployment"


############################################# Login #############################################
echo "----------------------- SSH Keys and Login ----------------------------"
echo ""

# Navigate to Azure Portal
echo "Navigate to Azure Portal where you will create the resources..."

# Retrieve tenant ID
echo "Copy the tenant ID from the Azure Portal and paste it here:" & read TENANT_ID
echo "Tenant ID: $TENANT_ID"

# Login to Azure
echo "Login to Azure..."
az login --tenant $TENANT_ID

# Get Subscription
echo "Get SubscriptionID from the displayed JSON and paste here:" & read SUBSCRIPTION_ID
echo "Subscription ID: $SUBSCRIPTION_ID"

# Set Account
echo "Set Account..."
az account set --subscription $SUBSCRIPTION_ID
echo "Account set to $SUBSCRIPTION_ID"

############################################# Delete AAD Resources #############################################
echo "----------------------- DELETE AAD Resources ----------------------------"
echo ""

# Properties for appDevUser
AADUSR_DEV_UPN="appdev@"$domain

# Properties for opsSREUser
AADUSR_SRE_UPN="opssre@"$domain

# Delete AAD Group appdev
echo "Delete AAD Group appdev..."
az ad group delete --group appdev
echo "AAD Group appdev deleted"

# Delete AAD Group opssre..."
echo "Delete AAD Group opssre..."
az ad group delete --group opssre
echo "AAD Group opssre deleted"

# Delete AAD User AADUSR_AKSDEV
echo "Delete AAD User AADUSR_AKSDEV..."
az ad user delete --id $AADUSR_DEV_UPN
echo "AAD User AADUSR_AKSDEV deleted"

# Delete AAD User AADUSR_AKSSRE
echo "Delete AAD User AADUSR_AKSSRE..."
az ad user delete --id $AADUSR_SRE_UPN
echo "AAD User AADUSR_AKSSRE deleted"

############################################# Delete Subscription Resources #############################################
echo "----------------------- Delete Subscription Resources ----------------------------"
echo ""

# Delete Deployment Subscription 'main'
echo "Delete Deployment Subscription 'main'..."
az deployment sub delete --name $deployment_name
echo "Deployment Subscription 'main' deleted"

# Delete Resource Groups
echo "Delete Resource Groups..."
for rg in $(az group list --query "[].name" -o tsv); 
do 
    echo 'Deleting ' $rg '...'; 
    az group delete --name $rg --yes; 
done;

        
