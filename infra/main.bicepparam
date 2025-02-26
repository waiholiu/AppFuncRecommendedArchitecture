using './main.bicep'

param appResourceGroup = 'poc4-xxx'
param vnetAddressRange = '10.0.0.0/16'
param vnetResourceGroup = 'vnet4-xxx'
param vnetName = 'vnet4-xxx'

// subnetApp
param subnetAppNSGName = 'sn-app-nsg'
param subnetAppName = 'sn-app'
param subnetAppAddressRange = '10.0.6.0/24'
// Subnet1 : 
param subnetDbNSGName = 'sn-db-nsg'
param subnetDbName = 'sn-db'
param subnetDbAddressRange = '10.0.7.0/24'
// Subnet1 : 
param subnetPENSGName = 'sn-pe-nsg'
param subnetPEName = 'sn-pe'
param subnetPEAddressRange = '10.0.8.0/24'

param appName = 'wl-xxx-backend-app'
param runtime = 'dotnet'

param sqlResourceGroup = 'poc4-xxx-db'
param sqlServerName = 'wl-xxx-db-server'

param sqlDBName = 'db'

param aadAdminObjectId = 'xxx'

param aadAdminLogin = 'xxx'

param frontDoorProfileName  = 'xxxFrontDoor4'
param frontDoorOriginGroupName  = 'xxxOriginGroup4'
param frontDoorOriginName  = 'xxxAppServiceOrigin4'
param frontDoorRouteName  = 'xxxRoute4'


