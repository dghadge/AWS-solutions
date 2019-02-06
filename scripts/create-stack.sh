#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Enter stack-name to create and json file"
    exit 0
fi

#ran=$(( ( RANDOM % 10 )  + 1 ))
#echo "Using stackname :infomagic-"$ran
 
aws cloudformation create-stack --stack-name $1 --template-body file://$2.json --parameters file://$2-parameters.json --capabilities CAPABILITY_IAM --profile saml
