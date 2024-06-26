param appInsightsName string
param tags object = {}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: resourceGroup().location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
  }
}
