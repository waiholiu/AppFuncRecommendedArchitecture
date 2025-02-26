# Define the resource group name based on the uniqueAppId
resourceGroupName="poc3-xxx"
dbResourceGroupName="poc3-xxx-db"
vnetResourceGroup="vnet3-xxx"


az group create --name $resourceGroupName --location australiaeast --tags purpose='build a xxx POC' url='xxxo'
az group create --name $dbResourceGroupName --location australiaeast --tags purpose='build a xxx POC' url='xxx'
az group create --name $vnetResourceGroup --location australiaeast --tags purpose='build a xxx POC' url='xxx'

frontdoorId=$(az deployment group create --resource-group $resourceGroupName --template-file main.bicep --parameters main.bicepparam --query properties.outputs.frontDoorId.value -o tsv)

# frontDoorId=$(echo $deploymentOutput | python -c "import sys, json; print(json.load(sys.stdin)['frontDoorId']['value'])")

echo "deploymentoutput $frontdoorId"
# echo "Front Door ID: $frontDoorId"

appName="wl-xxx-backend-app"

# see https://learn.microsoft.com/en-us/cli/azure/webapp/config/access-restriction?view=azure-cli-latest#az-webapp-config-access-restriction-add
az webapp config access-restriction add -g $resourceGroupName -n $appName --priority 400 --service-tag AzureFrontDoor.Backend --http-header x-azure-fdid=$frontdoorId
# Set the default network restriction to deny
az webapp config access-restriction set --resource-group $resourceGroupName --name $appName --use-same-restrictions-for-scm-site true --default-action Deny

echo "Network access restriction added to $appName to allow only Front Door ID: $frontdoorId"
