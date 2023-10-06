targetScope = 'subscription'

@description('The Azure Region in which all resources in this example should be created.')
param location string = ''

@description('The ssh public key rsa string to use for authentication')
param sshPublicKey string = ''

@description('The username for the Linux VMs')
var linuxAdminUsername = 'ktbaksmodule6user'

@description('Create resource group')
resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: 'ktb-aks-module6-rg'
  location: location
}

@description('Create the AAD Group appdev')
module aad_group_appdev 'aad_group.bicep' = {
  scope: rg
  name: 'aad_group_appdev'
  params: {
    name: 'appdev'
    location: location
  }
}  

@description('Create the AAD Group opssre')
module aad_group_opssre 'aad_group.bicep' = {
  scope: rg
  name: 'aad_group_opssre'
  params: {
    name: 'opssre'
    location: location
  }
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
module aks'aks.bicep' = {
  scope: rg
  name: 'aks'
  params: {
    location: location
    linuxAdminUsername: linuxAdminUsername
    sshRSAPublicKey: sshKey.outputs.sshKey
  }
}
