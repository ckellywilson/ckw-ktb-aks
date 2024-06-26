// target scope
targetScope = 'subscription'

// parameters
param resourceGroupName string
param location string
param keyData string
param adminUserId string
param tags object

// variables
var aksName = 'ktb-mod4-aks'
var adminUserName = 'ktbuser'
var nodeSize = 'Standard_DS4_v2'
var acrName = 'ktbmod4acr${uniqueString(resourceGroupName)}'
var keyVaultName = 'ktbmod4kv${uniqueString(resourceGroupName)}'
var logAnalyticsWorkspaceName = 'ktbmod4law${uniqueString(resourceGroupName)}'
var diagnosticsName = 'ktbmod4diag${uniqueString(resourceGroupName)}'
var appInsightsChainedName = 'ktbmod4ai-chained-${uniqueString(resourceGroupName)}'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module appInsightsChained 'ai.bicep' = {
  scope: rg
  name: 'appInsightsChained'
  params: {
    appInsightsName: appInsightsChainedName
    tags: tags
  }
}

module sshKey 'sshKey.bicep' = {
  scope: rg
  name: 'sshKey'
  params: {
    sshKeyName: 'ktb-mod4-ssh-key'
    keyData: keyData
    tags: tags
  }
}

module kv 'kv.bicep' = {
  scope: rg
  name: 'keyVault'
  params: {
    keyVaultName: keyVaultName
    adminUserId: adminUserId
    tags: tags
  }
}

module acr 'acr.bicep' = {
  scope: rg
  name: 'acr'
  params: {
    acrName: acrName
    tags: tags
  }
}

module law 'law.bicep' = {
  name: 'law'
  scope: rg
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    tags: tags
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
    logAnalyticsWorkspaceResourceId: law.outputs.logAnalyticsWorkspaceId
    diagnosticsName: diagnosticsName
    tags: tags
  }
}

output resourceGroupName string = rg.name
output acrName string = acr.outputs.acrName
output aksName string = aks.outputs.aksName
