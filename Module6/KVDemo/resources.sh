# variables
region="eastus"

# Create ssh keys
echo "Create ssh keys..."
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N ""
echo "SSH keys created"
sshPublicKey=$(cat ~/.ssh/id_rsa.pub)

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

# Create AAD Group appdev
APPDEV_ID=$(az ad group create --display-name appdev --mail-nickname appdev --query Id  --output tsv)
echo "AAD Group appdev created with ID: $APPDEV_ID"

# Create AAD Group opssre
OPSSRE_ID=$(az ad group create --display-name opssre --mail-nickname opssre --query Id  --output tsv)
echo "AAD Group opssre created with ID: $OPSSRE_ID"

# Create deployment
echo "Create deployment..."
az deployment sub create --location $region --template-file bicep/main.bicep --parameters location=$region sshPublicKey="$sshPublicKey"
