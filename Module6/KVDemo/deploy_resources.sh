# variables

region="eastus"
domain="ckwilson4gmail.onmicrosoft.com"
RG_NAME="ktb-aks-module6-rg"
AKS_CLUSTER_NAME="ktb-aks-module6"
deployment_name="ktb-aks-module6-deployment"


############################################# SSH Keys and Login #############################################
echo "----------------------- SSH Keys and Login ----------------------------"
echo ""

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

# Get Current User Group ID
echo "Get Current User Group ID by entering the name of a group for which you are a member here:" & read CURRENT_USER_GROUP_NAME
echo "Current User Group Name: $CURRENT_USER_GROUP_NAME"
CURRENT_USER_GROUP_ID=$(az ad group show --group "$CURRENT_USER_GROUP_NAME" --query 'id' --output tsv)
echo "Current User Group ID: $CURRENT_USER_GROUP_ID"

############################################# Create AAD Resources #############################################
echo "----------------------- Create AAD Resources ----------------------------"
echo ""

# Create AAD Group appdev
echo "Create AAD Group appdev..."
az ad group create --display-name appdev --mail-nickname appdev
echo "AAD Group appdev created"

# Assign AAD Group appdev to AADGRP_APPDEV_ID
echo "Assign AAD Group appdev to AADGRP_APPDEV_ID..."
AADGRP_APPDEV_ID=$(az ad group show --group appdev --query 'id' --output tsv)
echo "AAD Group appdev created with ID: $AADGRP_APPDEV_ID"

# Create AAD Group opssre..."
echo "Create AAD Group opssre..."
az ad group create --display-name opssre --mail-nickname opssre
echo "AAD Group opssre created"

# Assign AAD Group opssre to AADGRP_OPSSRE_ID
echo "Assign AAD Group opssre to AADGRP_OPSSRE_ID..."
AADGRP_OPSSRE_ID=$(az ad group show --group opssre --query 'id' --output tsv)
echo "AAD Group opssre created with ID: $AADGRP_OPSSRE_ID"

# Retrieve AAD Built-in Role ID
echo "Retrieve AAD Built-in Role ID, 'Azure Kubernetes Service Cluster User Role'..."
AKS_SVC_CLST_USER_ROLE=$(az role definition list --query "[?roleName=='Azure Kubernetes Service Cluster User Role'].name" --output tsv)
echo "AAD Built-in Role ID, 'Azure Kubernetes Service Cluster User Role': $AKS_SVC_CLST_USER_ROLE"

# Properties for appDevUser
AADUSR_DEV_UPN="appdev@"$domain
AADUSR_DEV_PW="P@ssw0rd1234!"

# Properties for opsSREUser
AADUSR_SRE_UPN="opssre@"$domain
AADUSR_SRE_PW="P@ssw0rd1234!"

# Create AADUSR_AKSDEV User
echo "Create AADUSR_AKSDEV User..."
az ad user create \
  --display-name "AKS Dev" \
  --user-principal-name $AADUSR_DEV_UPN \
  --password $AADUSR_DEV_PW
  echo "AADUSR_AKSDEV User created"

# Assign AADUSR_AKSDEV User to AADGRP_APPDEV_ID
echo "Assign AADUSR_AKSDEV User to AADGRP_APPDEV_ID..."
AADUSR_AKSDEV_ID=$(az ad user show --id $AADUSR_DEV_UPN --query id -o tsv)
echo "AADUSR_AKSDEV User created with ID: $AADUSR_AKSDEV_ID"

# Create AADUSR_AKSSRE User
echo "Create AADUSR_AKSSRE User..."
az ad user create \
  --display-name "AKS SRE" \
  --user-principal-name $AADUSR_SRE_UPN \
  --password $AADUSR_SRE_PW
  echo "AADUSR_AKSSRE User created"

# Assign AADUSR_AKSSRE User to AADGRP_OPSSRE_ID
echo "Assign AADUSR_AKSSRE User to AADGRP_OPSSRE_ID..."
AADUSR_AKSSRE_ID=$(az ad user show --id $AADUSR_SRE_UPN --query id -o tsv)
echo "AADUSR_AKSSRE User created with ID: $AADUSR_AKSSRE_ID"

# add AADUSR_AKSDEV to AADGRP_APPDEV
echo "Add AADUSR_AKSDEV to AADGRP_APPDEV..."
az ad group member add --group $AADGRP_APPDEV_ID --member-id $AADUSR_AKSDEV_ID
echo "AADUSR_AKSDEV added to AADGRP_APPDEV"

# add AADUSR_AKSSRE to AADGRP_OPSSRE
echo "Add AADUSR_AKSSRE to AADGRP_OPSSRE..."
az ad group member add --group $AADGRP_OPSSRE_ID --member-id $AADUSR_AKSSRE_ID
echo "AADUSR_AKSSRE added to AADGRP_OPSSRE"

############################################# Create main Resources #############################################
echo "----------------------- Create main Resources ----------------------------"
echo ""

# Create deployment
echo "Create deployment..."
az deployment sub create --name $deployment_name --location $region --template-file bicep/main.bicep \
    --parameters \
        rgName=$RG_NAME \
        aksClusterName=$AKS_CLUSTER_NAME \
        location=$region \
        sshPublicKey="$sshPublicKey" \
        aksClusterUserRoleId=$AKS_SVC_CLST_USER_ROLE \
        appDevGroupId=$AADGRP_APPDEV_ID \
        opsSREGroupId=$AADGRP_OPSSRE_ID \

############################################# Create Kubernetes Resources #############################################
echo "----------------------- Create Kubernetes Resources ----------------------------"
echo ""

# Get AKS Admin Credentials
echo "Get AKS Admin Credentials..."
az aks get-credentials --resource-group $RG_NAME --name $AKS_CLUSTER_NAME --admin
echo "AKS Admin Credentials retrieved"

# Replace 'groupObjectId' in k8s/aad-aks-cluster-admin-crb-template.yaml
echo "Replace 'groupObjectId' in k8s/aad-aks-cluster-admin-crb-template.yaml with '$CURRENT_USER_GROUP_ID'"
sed "s/groupObjectId/$CURRENT_USER_GROUP_ID/g" k8s/aad-aks-cluster-admin-crb-template.yaml > k8s/aad-aks-cluster-admin-crb.yaml
echo "Replaced 'groupObjectId' in k8s/aad-aks-cluster-admin-crb-template.yaml with '$CURRENT_USER_GROUP_ID' to k8s/aad-aks-cluster-admin-crb.yaml"


# Replace 'groupObjectId' in k8s/dev-user-access-rb-template.yaml
echo "Replace 'groupObjectId' in k8s/dev-user-access-rb-template.yaml with '$AADGRP_APPDEV_ID'"
sed "s/groupObjectId/$AADGRP_APPDEV_ID/g" k8s/dev-user-access-rb-template.yaml > k8s/dev-user-access-rb.yaml
echo "Replaced 'groupObjectId' in k8s/dev-user-access-rb-template.yaml with '$AADGRP_APPDEV_ID' to k8s/dev-user-access-rb.yaml"

# Replace 'groupObjectId' in k8s/sre-user-access-rb-template.yaml
echo "Replace 'groupObjectId' in k8s/sre-user-access-rb-template.yaml with '$AADGRP_OPSSRE_ID'"
sed "s/groupObjectId/$AADGRP_OPSSRE_ID/g" k8s/sre-user-access-rb-template.yaml > k8s/sre-user-access-rb.yaml
echo "Replaced 'groupObjectId' in k8s/sre-user-access-rb-template.yaml with '$AADGRP_OPSSRE_ID' to k8s/sre-user-access-rb.yaml"

# Apply K8s resources
echo "Apply K8s resources..."
kubectl apply -f k8s/

        
