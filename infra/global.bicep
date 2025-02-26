@export()
type GlobalParams = {
  appResourceGroup: string
  vnetAddressRange: string
  vnetResourceGroup: string
  vnetName: string
  subnetAppNSGName: string
  subnetAppName: string
  subnetAppAddressRange: string
  subnetDbNSGName: string
  subnetDbName: string
  subnetDbAddressRange: string
  subnetPENSGName: string
  subnetPEName: string
  subnetPEAddressRange: string

  appName: string
  runtime: string

  sqlResourceGroup: string
  sqlServerName: string
  sqlDBName: string
  aadAdminObjectId: string
  aadAdminLogin: string

  frontDoorEndpointName: string
  frontDoorProfileName: string
  frontDoorOriginGroupName: string
  frontDoorOriginName: string
  frontDoorRouteName: string
}
