@description('Name of the of the AAD Group')
param name string

@description('Location of the resource')
param location string

@description('Create AAD Group appdev')
resource aadgroup 'Microsoft.AAD/domainServices@2022-12-01' = {
  name: name
  location: location
}

output aadgroupid string = aadgroup.id
