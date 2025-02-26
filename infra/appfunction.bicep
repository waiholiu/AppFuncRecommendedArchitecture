import * as global from './global.bicep'

param GlobalParams global.GlobalParams


var hostingPlanName = GlobalParams.appName
var applicationInsightsName = GlobalParams.appName
var storageAccountName = '${uniqueString(resourceGroup().id)}azfunctions'
var storageAccountType = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: resourceGroup().location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
    minimumTlsVersion: 'TLS1_2'
  }
  
}

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: hostingPlanName
  location: resourceGroup().location
  kind: 'linux'
  sku: {
    name: 'P0v3'
    tier: 'PremiumV3'
  }
  properties: {
    reserved: true
  }
}


resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: GlobalParams.vnetName
  scope: resourceGroup(GlobalParams.vnetResourceGroup)
}

resource appSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  parent: vnet
  name: GlobalParams.subnetAppName
}

resource peSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  parent: vnet
  name: GlobalParams.subnetPEName
}


resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: GlobalParams.appName
  kind: 'functionapp,linux'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(GlobalParams.appName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
      ]
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
      }
      use32BitWorkerProcess: false
      ftpsState: 'FtpsOnly'
      linuxFxVersion: 'dotnet|isolated'
      alwaysOn: true
      minTlsVersion: '1.2'
    }
    clientAffinityEnabled: false
    virtualNetworkSubnetId: appSubnet.id
    publicNetworkAccess: 'Enabled'
    vnetRouteAllEnabled: true
    httpsOnly: true
    serverFarmId: hostingPlan.id
    
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}


// Private endpoint for the Function App
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: '${GlobalParams.appName}-pe'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: peSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${GlobalParams.appName}-connection'
        properties: {
          privateLinkServiceId: functionApp.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}



// Private DNS zone azurewebsite.net
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: 'privatelink.azurewebsites.net'
  scope: resourceGroup(GlobalParams.vnetResourceGroup)
}

// Private DNS zone group for the Private Endpoint
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateEndpoint.name}-dns-zone-group'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink.azurewebsites.net'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}

