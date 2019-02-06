#!/bin/bash
export AWS_DEFAULT_REGION=us-east-1 
#Change the below, an s3 bucket to store lambda code for deploy, and output report
#Must be in same region as lambda (ie AWS_DEFAULT_REGION)
export BUCKET=ifi-cost-and-billing-reports
#Comma Seperated list of emails to send too
export SES_TO=dan.ghadge@stelligent.com,eric.grosskurth@informais.com,jessica.butler@informa.com,sonny.pham@informa.com,derick.stinson@informais.com
export SES_FROM=dan.ghadge@stelligent.com
export SES_REGION=us-east-1
#Comma Seperated list of Cost Allocation Tags (must be configured in AWS billing prefs)
#export COST_TAGS=CostGroup
#Do you want partial figures for the current month (set to true if running weekly/daily)
export CURRENT_MONTH=true

if [ ! -f bin/lambda.zip ]; then
    echo "lambda.zip not found! Please build before running deploy."
    exit
fi

cd src
zip -ur ../bin/lambda.zip lambda.py
cd ..
aws cloudformation package \
   --template-file src/sam.yaml \
   --output-template-file deploy.sam.yaml \
   --s3-bucket=danghadgeifi \
   --s3-prefix aws-cost-explorer-report-builds
aws cloudformation deploy \
  --template-file deploy.sam.yaml \
  --stack-name aws-cost-explorer-report \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides SESSendFrom=$SES_FROM S3Bucket=$BUCKET \
  SESSendTo=$SES_TO SESRegion=$SES_REGION \
  AccountLabel=Email ListOfCostTags=$COST_TAGS CurrentMonth=$CURRENT_MONTH
