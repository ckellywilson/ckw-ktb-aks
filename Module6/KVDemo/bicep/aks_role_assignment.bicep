@description('Specifies the role definition ID used in the role assignment.')
param roleDefinitionID string
@description('Specifies the principal ID assigned to the role.')
param principalId string
@description('AKS identity')
param aksId string


var roleAssignmentName= guid(principalId, roleDefinitionID, aksId)

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionID)
    principalId: principalId
  }
}
