import * as global from './global.bicep'

param GlobalParams global.GlobalParams

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: GlobalParams.vnetName
  scope: resourceGroup(GlobalParams.vnetResourceGroup)
}

resource sqlSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  parent: vnet
  name: GlobalParams.subnetDbName
}

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: GlobalParams.sqlServerName
  location: resourceGroup().location
  properties: {
    administrators: {
      azureADOnlyAuthentication: true
      administratorType: 'ActiveDirectory'
      login: GlobalParams.aadAdminLogin
      sid:GlobalParams.aadAdminObjectId
      tenantId: subscription().tenantId
    }
    publicNetworkAccess: 'Disabled'
  }
}

resource sqlDB 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: GlobalParams.sqlDBName
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

resource sqlPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: '${GlobalParams.sqlServerName}-pe'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: sqlSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${GlobalParams.sqlServerName}-sql-connection'
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

resource sqlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: 'privatelink.database.windows.net'
  scope: resourceGroup(GlobalParams.vnetResourceGroup)
}

resource sqlPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${sqlPrivateEndpoint.name}-dns-zone-group'
  parent: sqlPrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink.database.windows.net'
        properties: {
          privateDnsZoneId: sqlPrivateDnsZone.id
        }
      }
    ]
  }
}


resource functionApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: GlobalParams.appName
  scope: resourceGroup(GlobalParams.appResourceGroup)
}

resource sqlContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(sqlServer.id, functionApp.id, 'contributor')
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'b24988ac-6180-42a0-ab88-20f7382dd24c'
    ) // SQL DB Contributor
    principalId: functionApp.identity.principalId
  }
}

resource sqlReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(sqlServer.id, functionApp.id, 'reader')

  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'acdd72a7-3385-48ef-bd42-f606fba81ae7'
    ) // Reader
    principalId: functionApp.identity.principalId
  }
}



