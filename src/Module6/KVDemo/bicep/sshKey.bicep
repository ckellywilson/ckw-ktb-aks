@description('Cluster name')
var sshKeyName ='ktb-aks-ssh-key'

@description('Location')
param location string= ''

@description('SSH public key data')
param sshPublicKey string=''

resource sshKey 'Microsoft.Compute/sshPublicKeys@2023-07-01' = {
  name: sshKeyName
  location: location
  properties: {
    publicKey: sshPublicKey
  }
}

output sshKey string = sshKey.properties.publicKey
