param acrName string

resource acr 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: acrName
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
}

output acrId string = acr.id
output acrName string = acr.name
