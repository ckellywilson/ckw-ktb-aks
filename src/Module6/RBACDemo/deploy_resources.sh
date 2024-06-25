# variables

region="eastus"
domain=""
resource_prefix="ktb-aks-module6-rbac"
RG_NAME=$resource_prefix"-rg"
AKS_CLUSTER_NAME=$resource_prefix"-aks"
deployment_name=$resource_prefix"-deployment"


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

############################################# GET Logged-in User #############################################
# Get Logged-in User UPN
echo "Get Logged-in User UPN..."
LOGGED_IN_UPN=$(az ad signed-in-user show --query userPrincipalName --output tsv)
echo "Logged in UPN: $LOGGED_IN_UPN"
echo "Set domain to the domain of the logged-in user"
domain=${LOGGED_IN_UPN#*@}
echo "Current domain: $domain"

# Get Logged-in User ID
echo "Get Logged-in User ID..."
LOGGED_IN_USER_ID=$(az ad user show --id $LOGGED_IN_UPN --query id --output tsv)
echo "Logged in User ID: $LOGGED_IN_USER_ID"


############################################# Create AAD Resources #############################################
echo "----------------------- Create AAD Resources ----------------------------"
echo ""

# Create AAD Group mod6RBACAdmin - This group will be used to assign the Azure Kubernetes Service Cluster Admin Role
echo "Create AAD Group mod6RBACAdmin..."
az ad group create --display-name mod6RBACAdmin --mail-nickname mod6RBACAdmin
echo "AAD Group mod6RBACAdmin created"

# Assign AAD Group mod6RBACAdmin to AADGRP_MOD6RBACADMIN_ID
echo "Assign AAD Group mod6RBACAdmin to AADGRP_MOD6RBACADMIN_ID..."
AADGRP_MOD6RBACADMIN_ID=$(az ad group show --group mod6RBACAdmin --query 'id' --output tsv)
echo "AAD Group mod6RBACAdmin created with ID: $AADGRP_MOD6RBACADMIN_ID"

# Retrieve AAD 'Azure Kubernetes Service Cluster Admin Role' ID
echo "Retrieve AAD Built-in Role ID, 'Azure Kubernetes Service Cluster Admin Role'..."
AKS_SVC_CLST_ADMIN_ROLE=$(az role definition list --query "[?roleName=='Azure Kubernetes Service Cluster Admin Role'].name" --output tsv)
echo "AAD Built-in Role ID, 'Azure Kubernetes Service Cluster Admin Role': $AKS_SVC_CLST_ADMIN_ROLE"

# Assign Logged-in User to AAD Group mod6RBACAdmin
echo "Assign Logged-in User to AAD Group mod6RBACAdmin..."
az ad group member add --group $AADGRP_MOD6RBACADMIN_ID --member-id $LOGGED_IN_USER_ID
echo "Logged-in User assigned to AAD Group mod6RBACAdmin"

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

# Retrieve AAD 'Azure Kubernetes Service Cluster User Role' ID
echo "Retrieve AAD Built-in Role ID, 'Azure Kubernetes Service Cluster User Role'..."
AKS_SVC_CLST_USER_ROLE=$(az role definition list --query "[?roleName=='Azure Kubernetes Service Cluster User Role'].name" --output tsv)
echo "AAD Built-in Role ID, 'Azure Kubernetes Service Cluster User Role': $AKS_SVC_CLST_USER_ROLE"

# Properties for appDevUser
AADUSR_DEV_UPN="appdev@"$domain
AADUSR_DEV_PW="P@ssw0rd1234!"

# Properties for opsSREUser
AADUSR_SRE_UPN="opssre@"$domain
AADUSR_SRE_PW="P@ssw0rd2345!"

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
        mod6RBACAdminGroupId=$AADGRP_MOD6RBACADMIN_ID \

############################################# Create Kubernetes Resources #############################################
echo "----------------------- Create Kubernetes Resources ----------------------------"
echo ""

# Get AKS Admin Credentials
echo "Get AKS Admin Credentials..."
az aks get-credentials --resource-group $RG_NAME --name $AKS_CLUSTER_NAME --admin
echo "AKS Admin Credentials retrieved"

# Replace 'groupObjectId' in k8s/aad-aks-cluster-admin-crb-template.yaml
echo "Replace 'groupObjectId' in k8s/aad-aks-cluster-admin-crb-template.yaml with '$AADGRP_MOD6RBACADMIN_ID'"
sed "s/groupObjectId/$AADGRP_MOD6RBACADMIN_ID/g" k8s/aad-aks-cluster-admin-crb-template.yaml > k8s/aad-aks-cluster-admin-crb.yaml
echo "Replaced 'groupObjectId' in k8s/aad-aks-cluster-admin-crb-template.yaml with '$AADGRP_MOD6RBACADMIN_ID' to k8s/aad-aks-cluster-admin-crb.yaml"


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

        
