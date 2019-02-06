#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Enter stack-name to update"
    exit 0
fi

aws cloudformation update-stack --stack-name $1 --template-body file://$1.json --parameters file://$1-parameters.json --capabilities CAPABILITY_IAM --profile saml
