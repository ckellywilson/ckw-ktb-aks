// target scope
targetScope = 'resourceGroup'

// Variables
param adminUsername string
param clusterName string
param nodeCount int
param nodeSize string
param keyData string
param logAnalyticsWorkspaceResourceId string
param diagnosticsName string
param tags object = {}

// AKS Cluster
resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-03-02-preview' = {
  name: clusterName
  location: resourceGroup().location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: clusterName
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: nodeCount
        vmSize: nodeSize
        osType: 'Linux'
        mode: 'System'
        enableAutoScaling: true
        minCount: 3
        maxCount: 5
      }
    ]
    linuxProfile: {
      adminUsername: adminUsername
      ssh: {
        publicKeys: [
          {
            keyData: keyData
          }
        ]
      }
    }
    addonProfiles: {
      azurepolicy: {
        enabled: true
      }
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceResourceId
          useAADAuth: 'true'
        }
      }
    }
    azureMonitorProfile: {
      metrics: {
        enabled: false
      }
      containerInsights: {
        enabled: true
        logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
      }
    }
  }
}

resource diagLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticsName
  scope: aksCluster
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: [
      {
        category: 'kube-apiserver'
        enabled: true
      }
      {
        category: 'kube-controller-manager'
        enabled: true
      }
      {
        category: 'kube-scheduler'
        enabled: true
      }
      {
        category: 'cluster-autoscaler'
        enabled: true
      }
    ]
  }
}

output aksName string = aksCluster.name
output aksResourceId string = aksCluster.id
