#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage : mssql-restore.sh source-db-snapshot-identifier Name-of-target-db-snapshot-identifier"
    exit 0
fi

aws rds wait db-snapshot-available --db-snapshot-identifier $1
if [ $? -ne 0 ]; then
    echo "Snapshot \"$1\" does not exist in source region"
    exit 0
fi

export AWS_DEFAULT_REGION=eu-west-1

echo "Copying snapshot \"$1\" to $AWS_DEFAULT_REGION region"

aws rds copy-db-snapshot --source-db-snapshot-identifier $1 --target-db-snapshot-identifier $2 --copy-tags

echo "Waiting for snapshot \"$1\" to be available in $AWS_DEFAULT_REGION region"

aws rds wait db-snapshot-available --db-snapshot-identifier $2
if [ $? -ne 0 ]; then
    echo "Unable to copy snapshot \"$1\" to destination region"
    exit 0
fi

echo "Creating DB Instance from snapshot in $AWS_DEFAULT_REGION region"

aws cloudformation create-stack --stack-name iMagic-EUWEST --template-body file://mssql-rds.json --parameters file://mssql-rds-restore-to-euwest-parameters.json --capabilities CAPABILITY_IAM --profile saml
