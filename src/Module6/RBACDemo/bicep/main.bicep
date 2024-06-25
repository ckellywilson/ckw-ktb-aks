targetScope = 'subscription'

@description('Resource Group Name')
param rgName string = ''
@description('AKS Cluster Name')
param aksClusterName string = ''
@description('The Azure Region in which all resources in this example should be created.')
param location string = ''
@description('The ssh public key rsa string to use for authentication')
param sshPublicKey string = ''
@description('RoleDefinitionId for the \'Azure Kubernetes Service Cluster User Role\' role')
param aksClusterUserRoleId string = ''
@description('AAD Group Id for \'appdev\' group')
param appDevGroupId string = ''
@description('AAD Group Id for \'opssre\' group')
param opsSREGroupId string = ''
@description('AAD Group Id for \'RBAC Admin\' group')
param mod6RBACAdminGroupId string = ''

@description('The username for the Linux VMs')
var linuxAdminUsername = 'ktbaksmodule6user'

@description('Create resource group')
resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgName
  location: location
}

@description('Create the ssh key')
module sshKey 'sshKey.bicep' = {
  scope: rg
  name: 'sshKey'
  params: {
    sshPublicKey: sshPublicKey
    location: location
  }
}

@description('Create the AKS Cluster')
module aks 'aks.bicep' = {
  scope: rg
  name: 'aks'
  params: {
    location: location
    linuxAdminUsername: linuxAdminUsername
    sshRSAPublicKey: sshKey.outputs.sshKey
    aksClusterName: aksClusterName
    adminGroupObjectIDs: [mod6RBACAdminGroupId]
  }
}

@description('Assign the \'Azure Kubernetes Service Cluster User Role\' role to the \'appdev\' group')
module appdevRoleAssignment 'aks_role_assignment.bicep' = {
  scope: rg
  name: 'appdevRoleAssignment'
  params: {
    roleDefinitionID: aksClusterUserRoleId
    principalId: appDevGroupId
    aksId: aks.outputs.aksid
  }
}

@description('Assign the \'Azure Kubernetes Service Cluster User Role\' role to the \'opssre\' group')
module opssreRoleAssignment 'aks_role_assignment.bicep' = {
  scope: rg
  name: 'opssreRoleAssignment'
  params: {
    roleDefinitionID: aksClusterUserRoleId
    principalId: opsSREGroupId
    aksId: aks.outputs.aksid
  }
}
