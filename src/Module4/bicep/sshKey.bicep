targetScope = 'resourceGroup'

param keyData string
param sshKeyName string

resource sshKey 'Microsoft.Compute/sshPublicKeys@2024-03-01' = {
  name: sshKeyName
  location: resourceGroup().location
  properties: {
    publicKey: keyData
  }
}

output sshKey string = sshKey.properties.publicKey
