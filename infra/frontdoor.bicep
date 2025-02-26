import * as global from './global.bicep'

param GlobalParams global.GlobalParams

var frontDoorSkuName = 'Standard_AzureFrontDoor'

resource frontDoorProfile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: GlobalParams.frontDoorProfileName
  location: 'global'
  sku: {
    name: frontDoorSkuName
  }
}

resource app 'Microsoft.Web/sites@2020-06-01' existing = {
  name: GlobalParams.appName
  scope:  resourceGroup(GlobalParams.appResourceGroup)
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: GlobalParams.frontDoorEndpointName
  parent: frontDoorProfile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: GlobalParams.frontDoorOriginGroupName
  parent: frontDoorProfile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
  }
}

resource frontDoorOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  name: GlobalParams.frontDoorOriginName
  parent: frontDoorOriginGroup
  properties: {
    hostName: app.properties.defaultHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: app.properties.defaultHostName
    priority: 1
    weight: 1000
  }
}

resource frontDoorRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: GlobalParams.frontDoorRouteName
  parent: frontDoorEndpoint
  dependsOn: [
    frontDoorOrigin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {
    originGroup: {
      id: frontDoorOriginGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

output appServiceHostName string = app.properties.defaultHostName
output frontDoorEndpointHostName string = frontDoorEndpoint.properties.hostName
output frontDoorId string = frontDoorProfile.properties.frontDoorId
