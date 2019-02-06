#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Enter stack-name to update"
    exit 0
fi

aws cloudformation delete-stack --stack-name $1 --profile saml
