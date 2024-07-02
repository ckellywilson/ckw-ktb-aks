// target scope
targetScope = 'resourceGroup'

// Variables
param adminUsername string
param clusterName string
param nodeCount int
param nodeSize string
param keyData string
param tags object = {}
param logAnalyticsWorkspaceId string

// variables
var diagnosticsSettingName = '${clusterName}-diagnostics'

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

resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticsSettingName
  scope: aksCluster
  properties: {
    logs: [
      {
        category: 'kube-audit-admin'
        enabled: true       
      }
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
      {
        category: 'cloud-controller-manager'
        enabled: true       
      }
      {
        category: 'guard'
        enabled: true     
      }
      {
        category: 'csi-azuredisk-controller'
        enabled: true       
      }
      {
        category: 'csi-azurefile-controller'
        enabled: true        
      }
      {
        category: 'csi-snapshot-controller'
        enabled: true      
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true      
      }
    ]
    workspaceId: logAnalyticsWorkspaceId
  }
}

// Output
output aksName string = aksCluster.name
output aksResourceId string = aksCluster.id
