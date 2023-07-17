#!/bin/bash

if [[ $# -ne 1 ]]; then
    printf "Error. Usage: ./$0 RG_NAME"
    exit 1
fi

az group delete \
    --resource-group $1 \
    --yes
