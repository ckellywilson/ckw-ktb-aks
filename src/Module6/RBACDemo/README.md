# Demo Azure Kubernetes Service with Azure AAD (now Microsoft Entra ID) with Kubernetes RBAC
This demo provides for automated deployment to a target Subscription for the public documentation [Use Kubernetes role-based access control with Azure Active Directory in Azure Kubernetes Service](https://learn.microsoft.com/en-us/azure/aks/azure-ad-rbac?tabs=portal)

To execute this demo:
- Ensure [kubelogin](https://learn.microsoft.com/en-us/azure/aks/enable-authentication-microsoft-entra-id#non-interactive-sign-in-with-kubelogin) is installed for your client
- In the [Azure Portal](https://portal.azure.com), find a group for which you are a member (Microsoft Entra ID --> Users --> Select your user and find group memberships).
- Navigate to [Azure Portal](https://portal.azure.com) of the subscription you wish to use.
- Prepare the [deploy_resources.sh](deploy_resources.sh) file by setting the variables.
    - Set the domain to "eastus"
    - Retrieve [Domain](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/Overview) by copying _Primary Domain_ property
- Execute the [deploy_resources.sh](deploy_resources.sh) file.
    - Retrieve [Tenant ID](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/Overview) by copying _Tenant ID_ property
    - Retrieve [Subscription ID](https://portal.azure.com/#view/Microsoft_Azure_Billing/SubscriptionsBlade) by copying the "Subscription ID"
    - Finding a Group Name for which you are a member.
    - In bash or zsh, execute chmod +X [deploy_resources.sh](deploy_resources.sh) and follow prompts.

After creating the resources
- [Interact with cluster resources using Azure AD identities](https://learn.microsoft.com/en-us/azure/aks/azure-ad-rbac?tabs=portal#interact-with-cluster-resources-using-azure-ad-identities)
- _NOTE: If using MacOS, before you execute kubectl get-credentials, you must delete the .kube cache folder by running rm -rf ~/.kube/cache_


