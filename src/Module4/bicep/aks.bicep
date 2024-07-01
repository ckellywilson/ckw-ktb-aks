// target scope
targetScope = 'resourceGroup'

// Variables
param adminUsername string
param clusterName string
param nodeCount int
param nodeSize string
param keyData string
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
    azureMonitorProfile: {
      metrics: {
        enabled: false
      }
      containerInsights: {
        enabled: false
      }
    }
  }
}

// Output
output aksName string = aksCluster.name
output aksResourceId string = aksCluster.id
