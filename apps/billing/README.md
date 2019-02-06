## AWS Cost Explorer Report Generator

Python SAM Lambda module for generating an Excel cost report with graphs, including month on month cost changes. Uses the AWS Cost Explorer API for data.

![screenshot](https://github.com/InformaFI/AWSMigration/blob/master/apps/billing/screenshot.png)

## Building
Run build.sh to build a new lambda deployment package.
This requires Docker, as it builds the package in an Amazon Linux container.

#### `sh build.sh`

## Deploying
Update the values in deploy.sh for your AWS account details.  
S3_BUCKET: S3 Bucket to use  
SES_SEND: Email list to send to (comma separated)  
SES_FROM: SES Verified Sender Email  
SES_REGION: SES Region  
COST_TAGS: List Of Cost Tag Keys (comma separated)  
CURRENT_MONTH: true | false for if report does current partial month

And then run deploy.sh

#### `sh deploy.sh`

## Manually Running / Testing
Once the lambda is created, find it in the AWS Lambda console.
You can create ANY test event (as the event content is ignored), and hit the test button for a manual run.

## Customise the report
Add verification email to SES by 
1. Login to appropriate AWS account and click
  https://console.aws.amazon.com/ses/home?region=us-east-1#verified-senders-email:
2. Click button "Verify a New Email Address" and add the new email to verify

Change email recipients by
1. Login to appropriate AWS account and click 
  https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions/CostExplorerReportLambda?tab=graph
2. Browse to section where you will find "Environment variables" as shown below
  ![screenshot](https://github.com/InformaFI/AWSMigration/blob/master/apps/billing/env-vars.png)

Edit the last segment of src/lambda.py

```python
def main_handler(event=None, context=None): 
  costexplorer = CostExplorer(CurrentMonth=False)
  #Default addReport has filter to remove Credits / Refunds / UpfrontRI
  costexplorer.addReport(Name="Total", GroupBy=[],Style='Total')
  costexplorer.addReport(Name="TotalChange", GroupBy=[],Style='Change')
  costexplorer.addReport(Name="TotalInclCredits", GroupBy=[],Style='Total',NoCredits=False)
  costexplorer.addReport(Name="TotalInclCreditsChange", GroupBy=[],Style='Change',NoCredits=False)
  costexplorer.addReport(Name="Credits", GroupBy=[],Style='Total',CreditsOnly=True)
  costexplorer.addReport(Name="RIUpfront", GroupBy=[],Style='Total',UpfrontOnly=True)

  costexplorer.addRiReport(Name="RICoverage")
  costexplorer.addReport(Name="Services", GroupBy=[{"Type": "DIMENSION","Key": "SERVICE"}],Style='Total')
  costexplorer.addReport(Name="ServicesChange", GroupBy=[{"Type": "DIMENSION","Key": "SERVICE"}],Style='Change')
  costexplorer.addReport(Name="Accounts", GroupBy=[{"Type": "DIMENSION","Key": "LINKED_ACCOUNT"}],Style='Total')
  costexplorer.addReport(Name="AccountsChange", GroupBy=[{"Type": "DIMENSION","Key": "LINKED_ACCOUNT"}],Style='Change')
  costexplorer.addReport(Name="Regions", GroupBy=[{"Type": "DIMENSION","Key": "REGION"}],Style='Total')
  costexplorer.addReport(Name="RegionsChange", GroupBy=[{"Type": "DIMENSION","Key": "REGION"}],Style='Change')
  if os.environ.get('COST_TAGS'): #Support for multiple/different Cost Allocation tags
      for tagkey in os.environ.get('COST_TAGS').split(','):
          tabname = tagkey.replace(":",".") #Remove special chars from Excel tabname
          costexplorer.addReport(Name="{}".format(tabname)[:31], GroupBy=[{"Type": "TAG","Key": tagkey}],Style='Total')
          costexplorer.addReport(Name="Change-{}".format(tabname)[:31], GroupBy=[{"Type": "TAG","Key": tagkey}],Style='Change')
  costexplorer.generateExcel()
  return "Report Generated"
```