// target scope
targetScope = 'subscription'

param resourceGroupName string
param location string
param keyData string

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

module aks 'aks.bicep' = {
  scope: rg
  name: 'aks'
  params: {
    adminUsername: 'ktbuser'
    clusterName: 'ktb-aks'
    nodeCount: 3
    nodeSize: 'Standard_D2ds_v5'
    keyData: sshKey.outputs.sshKey
  }
}
