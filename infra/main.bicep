param vnetResourceGroup string
param  appResourceGroup string

// VNET.BICEP parameters

param vnetAddressRange string
param vnetName string
// Subnet1 : 
param subnetAppNSGName string
param subnetAppName string
param subnetAppAddressRange string
// Subnet1 : 
param subnetDbNSGName string
param subnetDbName string
param subnetDbAddressRange string
// Subnet1 : 
param subnetPENSGName string
param subnetPEName string
param subnetPEAddressRange string

param sqlResourceGroup string
// Appfunction.bicep parameters
@description('The name of the function app that you wish to create.')
param appName string

@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
  'dotnet'
  'java'
])
param runtime string = 'node'


// sql.bicep parameters
@description('The name of the SQL logical server.')
param sqlServerName string = uniqueString('sql', resourceGroup().id)

@description('The name of the SQL Database.')
param sqlDBName string = 'SampleDB'


@description('The Entra ID admin object ID.')
param aadAdminObjectId string

@description('The Entra ID admin login name.')
param aadAdminLogin string




@description('The name of the Front Door endpoint to create. This must be globally unique.')
param frontDoorEndpointName string = 'afd-${uniqueString(resourceGroup().id)}'


param frontDoorProfileName string = 'MyFrontDoor'
param frontDoorOriginGroupName string = 'MyOriginGroup'
param frontDoorOriginName string = 'MyAppServiceOrigin'
param frontDoorRouteName string = 'MyRoute'


import * as global from './global.bicep'

// populate global params 
param globalParams global.GlobalParams = {
  appResourceGroup:appResourceGroup
  vnetResourceGroup: vnetResourceGroup
  vnetName: vnetName
  subnetAppNSGName: subnetAppNSGName
  subnetAppName: subnetAppName
  subnetAppAddressRange: subnetAppAddressRange
  subnetDbNSGName: subnetDbNSGName
  subnetDbName: subnetDbName
  subnetDbAddressRange: subnetDbAddressRange
  subnetPENSGName: subnetPENSGName
  subnetPEName: subnetPEName
  subnetPEAddressRange: subnetPEAddressRange
  appName: appName
  runtime: runtime
  sqlResourceGroup:sqlResourceGroup
  sqlServerName:sqlServerName
  sqlDBName:sqlDBName
  aadAdminObjectId:aadAdminObjectId
  aadAdminLogin:aadAdminLogin
  vnetAddressRange:vnetAddressRange
  frontDoorEndpointName:frontDoorEndpointName
  frontDoorProfileName:frontDoorProfileName
  frontDoorOriginGroupName:frontDoorOriginGroupName
  frontDoorOriginName:frontDoorOriginName
  frontDoorRouteName:frontDoorRouteName
}

module vnetModule './vnet.bicep' = {
  name: 'vnetModule'
  scope: resourceGroup(globalParams.vnetResourceGroup)

  params: { GlobalParams: globalParams }
}


module appFunctionModule './appfunction.bicep' = {
  name: 'appFunctionModule'
  dependsOn: [
    vnetModule
  ]
  params: { GlobalParams: globalParams }
}

module frontDoorModule './frontdoor.bicep' = {
  name: 'frontDoorModule'
  dependsOn: [
    appFunctionModule
  ]
  params: { GlobalParams: globalParams }
}


module dbFunctionModule './sql.bicep' = {
  name: 'dbFunctionModule'
  scope: resourceGroup(globalParams.sqlResourceGroup)
  dependsOn: [
    vnetModule
  ]
  params: { GlobalParams: globalParams }
}



output frontDoorId string = frontDoorModule.outputs.frontDoorId
