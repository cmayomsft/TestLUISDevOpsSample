#!/bin/bash
# Get the Service Principal name
SP_DEFAULT="myLUISDevOpsApp"
read -p "Enter the Service Principal name [$SP_DEFAULT]: " spname
spname="${spname:-$SP_DEFAULT}"

# Get the resource group name
RG_DEFAULT="luisDevOpsRG"
read -p "Enter the Azure Resource Group name [$RG_DEFAULT]: " resourceGroup
resourceGroup="${resourceGroup:-$RG_DEFAULT}"

# get our subscriptionId
subscriptionId=$(az account show --query id -o tsv)

# create the SP
RBAC_TOKEN=$(az ad sp create-for-rbac --name "$spname" \
        --role "contributor" \
        --scope "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup" \
        --sdk-auth)

# get the app id of the service principal
servicePrincipalAppId=$(az ad sp list --display-name $spname --query "[].appId" -o tsv)

# grant Storage Blob Data Contributor access just to this resource group
az role assignment create --assignee $servicePrincipalAppId \
        --role "Storage Blob Data Contributor" \
        --scope "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup" 

# Show token
echo "Copy the following JSON and paste into a GitHub Secret called AZURE_CREDENTIALS:"
echo ""
echo $RBAC_TOKEN
echo ""