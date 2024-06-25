# variables
region="eastus"
domain="<your-domain>"
resource_prefix="ktb-aks-module6-rbac"
AKS_CLUSTER_NAME="ktb-aks-module6"
deployment_name="ktb-aks-module6-deployment"


############################################# Login #############################################
echo "----------------------- SSH Keys and Login ----------------------------"
echo ""

# Navigate to Azure Portal
echo "Navigate to Azure Portal where you will create the resources..."

# Login to Azure
echo "Login to Azure..."
az login --use-device-code

# Get Subscription
echo "Get SubscriptionID from the displayed JSON and paste here:" & read SUBSCRIPTION_ID
echo "Subscription ID: $SUBSCRIPTION_ID"

# Set Account
echo "Set Account..."
az account set --subscription $SUBSCRIPTION_ID
echo "Account set to $SUBSCRIPTION_ID"

############################################# GET DOMAIN #############################################
LOGGED_IN_UPN=$(az ad signed-in-user show --query userPrincipalName --output tsv)
echo 'Logged in UPN ' $LOGGED_IN_UPN
domain=${LOGGED_IN_UPN#*@}
echo 'Current domain: '$domain

############################################# Delete AAD Resources #############################################
echo "----------------------- DELETE AAD Resources ----------------------------"
echo ""

# Properties for appDevUser
AADUSR_DEV_UPN="appdev@"$domain

# Properties for opsSREUser
AADUSR_SRE_UPN="opssre@"$domain

# Delete AAD Group mod6RBACAdmin
echo "Delete AAD Group mod6RBACAdmin..."
az ad group delete --group mod6RBACAdmin
echo "AAD GROUP mod6RBACAdmin deleted"

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
for rg in $(az group list --query "[?contains(name,'$resource_prefix')].name" -o tsv); 
do 
    echo 'Deleting ' $rg '...'; 
    az group delete --name $rg --yes; 
done;

        
