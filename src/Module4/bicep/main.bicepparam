using './main.bicep'

param resourceGroupName = ''
param location = ''
param keyData = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD'
param adminUserId = ''
param tags = {
  project: 'ktb-mod4'
}

