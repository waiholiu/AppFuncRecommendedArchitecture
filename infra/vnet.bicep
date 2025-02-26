import * as global from './global.bicep'

param GlobalParams global.GlobalParams

// Create a new virtual network
resource newVnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: GlobalParams.vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        GlobalParams.vnetAddressRange
      ]
    }
    subnets: [
      {
        name: GlobalParams.subnetAppName
        properties: {
          addressPrefix: GlobalParams.subnetAppAddressRange
          networkSecurityGroup: {
            id: subnetAppNSG.id
          }
          delegations: [
            {
              name: 'Microsoft.Web/serverFarms'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: GlobalParams.subnetDbName
        properties: {
          addressPrefix: GlobalParams.subnetDbAddressRange
          networkSecurityGroup: {
            id: subnetDbNSG.id
          }
        }
      }
      {
        name: GlobalParams.subnetPEName
        properties: {
          addressPrefix: GlobalParams.subnetPEAddressRange
          networkSecurityGroup: {
            id: subnetPENSG.id
          }
        }
      }
    ]
  }
}

// Apps subnet
resource subnetAppNSG 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: GlobalParams.subnetAppNSGName
  location: resourceGroup().location
  properties: {}
}

// Db subnet
resource subnetDbNSG 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: GlobalParams.subnetDbNSGName
  location: resourceGroup().location
  properties: {}
}

// Private endpoint subnet
resource subnetPENSG 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: GlobalParams.subnetPENSGName
  location: resourceGroup().location
  properties: {}
}

// Private DNS zone azurewebsite.net
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azurewebsites.net'
  location: 'global'
  properties: {}
}

// Link the DNS zone to the VNet
resource privateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  name: '${privateDnsZone.name}-${newVnet.name}-link'
  parent: privateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: newVnet.id
    }
    registrationEnabled: false
  }
}

// Private DNS zone azurewebsite.net
resource privateDnsSqlZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.database.windows.net'
  location: 'global'
  properties: {}
}

// Link the DNS zone to the VNet
resource privateDnsZoneSqlVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  name: '${privateDnsSqlZone.name}-${newVnet.name}-link'
  parent: privateDnsSqlZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: newVnet.id
    }
    registrationEnabled: false
  }
}
