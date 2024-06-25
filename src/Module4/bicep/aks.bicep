// target scope
targetScope = 'resourceGroup'

// Variables
param adminUsername string
param clusterName string
param nodeCount int
param nodeSize string
param keyData string

// AKS Cluster
resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: resourceGroup().location
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
  }
}

output aksClusterName string = aksCluster.name
