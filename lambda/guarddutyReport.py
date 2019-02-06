#lamdba function to ingest CloudWatch GuardDuty event and dump them into S3

from __future__ import print_function
from datetime import datetime
import json
import boto3
import botocore
import os

s3client = boto3.client('s3')

def lambda_handler(event, context):

    #print event 
    print(json.dumps(event))

    datestring = datetime.strftime(datetime.now(), '%m%Y')
    filename = 'monthlyreport_idip_' + datestring + '.txt'
    bucket = os.getenv('S3_DEST_BUCKET', default='ifi-reports')
    key = 'guardduty/' + filename
    
    recordId    = event['id']
    time        = event['time']
    accountId   = event['detail']['accountId']
    title       = event['detail']['title']
    description = event['detail']['description']

    local_filename = '/tmp/' + filename
    fileNotFound = False

    #IMP -- To create a new report every month; we're appending the date to the filename.
    # So when a new month starts, the report file will need to be created.
    try:
        s3client.download_file(bucket, key, local_filename)
    except botocore.exceptions.ClientError as e:
        if e.response['Error']['Code'] == "404":
            fileNotFound = True
    
    with open(local_filename, 'a') as outfile: 
        if fileNotFound:
            #create header records when the file is created at the beginning of the month
            outfile.write("\t\t\tIntrusion Detection Report for the month of " + datetime.strftime(datetime.now(), '%m/%Y') + "\n\n")
            outfile.write("RecordId        |       Time     |      Source AccountId     |      Title    |      Description\n")
            fileNotFound = False

        outfile.write("%s | %s | %s | %s | %s\n" % (recordId, time, accountId, title, description))
        
    #uplaod the report
    s3client.upload_file(local_filename, bucket, key)
