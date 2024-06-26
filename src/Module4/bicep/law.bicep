param logAnalyticsWorkspaceName string
param tags object = {}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: resourceGroup().location
  tags: tags
}

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
