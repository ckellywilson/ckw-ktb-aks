// target scope
targetScope = 'subscription'

param resourceGroupName string
param location string
param keyData string
param adminUserId string

// variables
var aksName = 'ktb-mod4-aks'
var adminUserName = 'ktbuser'
var nodeSize = 'Standard_D2ds_v5'
var acrName = 'ktbmod4acr${uniqueString(resourceGroupName)}'
var keyVaultName = 'ktbmod4kv${uniqueString(resourceGroupName)}'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module sshKey 'sshKey.bicep' = {
  scope: rg
  name: 'sshKey'
  params: {
    sshKeyName: 'ktb-mod4-ssh-key'
    keyData: keyData
  }
}

module kv 'kv.bicep' = {
  scope: rg
  name: 'keyVault'
  params: {
    keyVaultName: keyVaultName
    adminUserId: adminUserId
  }
}

module acr 'acr.bicep' = {
  scope: rg
  name: 'acr'
  params: {
    acrName: acrName
  }
}

module aks 'aks.bicep' = {
  scope: rg
  name: 'aks'
  params: {
    adminUsername: adminUserName
    clusterName: aksName
    nodeCount: 3
    nodeSize: nodeSize
    keyData: sshKey.outputs.sshKey
  }
}

output resourceGroupName string = rg.name
output acrName string = acr.outputs.acrName
output aksName string = aks.outputs.aksName
