# Define the resource group name based on the uniqueAppId
resourceGroupName="poc-xxx"
dbResourceGroupName="poc-xxx-db"
vnetResourceGroup="vnet-xxx"


az group delete --name $resourceGroupName --yes 
az group delete --name $dbResourceGroupName   --yes 
az group delete --name $vnetResourceGroup --yes 


