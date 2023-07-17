#!/bin/bash

AZURE_SA_NAME="testsa23402"
AZURE_RG_NAME="rg-testsa"
location="eastus"

az group show \
    --resource-group $AZURE_RG_NAME \
    2> /dev/null 1>&2

if [[ $? -ne 0 ]]; then
    printf "Creating %s resource group...\n" $AZURE_RG_NAME
    az group create \
	--location $location \
	--name $AZURE_RG_NAME
else
    printf "Skipping resource group creation. %s resource group already exists...\n" $AZURE_RG_NAME
fi


az storage account show \
    --name $AZURE_SA_NAME \
    2> /dev/null 1>&2

if [[ $? -ne 0 ]]; then
    printf "Creating %s storage account..." $AZURE_SA_NAME

    az storage account create \
	--name $AZURE_SA_NAME \
	--resource-group $AZURE_RG_NAME \
	--sku Standard_LRS \
	--location $location \
	--default-action Deny \
	--allow-blob-public-access false
else
    printf "Skipping storage creation. %s storage account already exists...\n" $AZURE_SA_NAME
fi

printf "Adding client IP to the %s storage account firewall rules...\n" $AZURE_SA_NAME
myIP=`dig +short myip.opendns.com @resolver2.opendns.com`
az storage account network-rule add \
    --account-name $AZURE_SA_NAME \
    --resource-group $AZURE_RG_NAME \
    --ip-address $myIP \
    2> /dev/null

if [[ $? -ne 0 ]]; then 
    printf "Could not add the client IP to the %s Storage Account firewall rules" $AZURE_SA_NAME
fi

AZURE_SA_CONN_STR=`az storage account show-connection-string \
		    --name $AZURE_SA_NAME \
		    --resource-group $AZURE_RG_NAME \
		    --query connectionString \
		    2> /dev/null`
if [[ $? -ne 0 ]]; then
    printf "Could export the %s Storage Account Connection String...\n" $AZURE_SA_NAME
fi


AZURE_SA_KEY=`az storage account keys list \
	    --account-name $AZURE_SA_NAME \
	    --resource-group $AZURE_RG_NAME \
	    --query "[?keyName=='key1'].value" --output tsv \
	    2> /dev/null`

if [[ $? -ne 0 ]]; then
    printf "Could export the %s Storage Account Key...\n" $AZURE_SA_NAME
fi

export AZURE_SA_CONN_STR
export AZURE_SA_KEY
export AZURE_SA_NAME
export AZURE_RG_NAME
