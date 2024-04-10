
@description('The location of the Managed Cluster resource.')
param location string = ''

@description('SSH RSA public key file path.')
param sshRSAPublicKey string = ''

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string  = 'ktb-aks-module6-kv-cluster-admin'

@description('The name of the Managed Cluster resource.')
param aksClusterName string = ''

@description('The object IDs of the Azure AD groups that will have admin access to the cluster.')
param adminGroupObjectIDs array = []

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
var dnsPrefix = 'ktb-aks-module6'

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
var osDiskSizeGB = 0

@description('The number of nodes for the cluster.')
var agentCount = 1

@description('The size of the Virtual Machine.')
var agentVMSize  = 'standard_d2s_v3'

resource aks 'Microsoft.ContainerService/managedClusters@2023-08-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: dnsPrefix
    networkProfile: {
      networkPlugin: 'azure'
    }
    // this will enable Kubernetes RBAC
    enableRBAC: true
    aadProfile: {
      managed: true
      // This will ensure that the cluster uses Azure AD for authentication with Kubernetes RBAC
      enableAzureRBAC: false
      adminGroupObjectIDs: adminGroupObjectIDs
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: agentCount
        vmSize: agentVMSize
        osDiskSizeGB: osDiskSizeGB
        mode: 'System'
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRSAPublicKey
          }
        ]
      }
    }
  }
}

output aksid string = aks.id
