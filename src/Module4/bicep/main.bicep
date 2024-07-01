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
var nodeSize = 'Standard_D2lds_v5'
var acrName = 'ktbmod4acr${uniqueString(resourceGroupName)}'
var keyVaultName = 'ktbmod4kv${uniqueString(resourceGroupName)}'
var logAnalyticsWorkspaceName = 'ktbmod4law${uniqueString(resourceGroupName)}'
var appInsightsChainedName = 'ktbmod4ai-chained-${uniqueString(resourceGroupName)}'
var dataCollectionInterval = '1m'

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
    tags: tags
  }
}

module aks_monitor 'aks-monitor.bicep' = {
  scope: rg
  name: 'aks-monitor'
  params: {
    aksResourceId: aks.outputs.aksResourceId
    aksResourceLocation: location
    resourceTagValues: tags
    workspaceResourceId: law.outputs.logAnalyticsWorkspaceId
    dataCollectionInterval: dataCollectionInterval
    enableContainerLogV2: true
    workspaceRegion: location
    namespaceFilteringModeForDataCollection: 'Include'
    namespacesForDataCollection: [
      'kube-system'
    ]
    streams: [
      'Microsoft-ContainerLog'
      'Microsoft-ContainerLogV2'
      'Microsoft-KubeEvents'
      'Microsoft-KubePodInventory'
      'Microsoft-KubeNodeInventory'
      'Microsoft-KubePVInventory'
      'Microsoft-KubeServices'
      'Microsoft-KubeMonAgentEvents'
      'Microsoft-InsightsMetrics'
      'Microsoft-ContainerInventory'
      'Microsoft-ContainerNodeInventory'
      'Microsoft-Perf'
    ]
  }
}

output resourceGroupName string = rg.name
output acrName string = acr.outputs.acrName
output aksName string = aks.outputs.aksName
