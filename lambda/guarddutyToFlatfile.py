#lamdba function to ingest CloudWatch GuardDuty event and dump them into S3

from __future__ import print_function
import json
import boto3
import gzip
import os
import uuid
import urllib
import re
import time
import random

s3 = boto3.resource('s3')
client = boto3.client('s3')

def convertColumntoLowerCaps(obj):
    if 'resources' in obj:
        del obj['resources']
        
    for key in obj.keys():
        new_key = re.sub(r'[\W]+', '', key)
        v = obj[key]
        if isinstance(v, dict):
            if len(v) > 0:
                convertColumntoLowerCaps(v)
        if new_key != key:
            obj[new_key] = obj[key]
            del obj[key]
    return obj

def lambda_handler(event, context):

    bucket = os.getenv('S3_DEST_BUCKET', default='ifi-guardduty')
    newKey = 'flatfiles/' + 'guarddutyevents' + str(uuid.uuid4()) + ".json.gz"
    print(json.dumps(event))

    #remove S3 put events
    if 'Records' in event:
        print("Not a GuardDuty event; skipping")
        return "success"

    #Append GuardDuty events in Records array
    data = {}  
    data['Records'] = []  
    data['Records'].append(event)
    with gzip.open('/tmp/guardduty.json.gz', 'w') as outfile:  
        json.dump(data, outfile)
        print(json.dumps(data))

    try:
        with gzip.open('/tmp/out.json.gz', 'w') as output, gzip.open('/tmp/guardduty.json.gz', 'rb') as file:
            i = 0
            for line in file: 
                for record in json.loads(line,object_hook=convertColumntoLowerCaps)['Records']:
                  if i != 0:
                      output.write("\n")
                  if 'responseelements' in record and record['responseelements'] != None and 'version' in record['responseelements']:
                      del record['responseelements']['version']
                  if 'requestparameters' in record and record['requestparameters'] != None and 'maxitems' in record['requestparameters']:
                      del record['requestparameters']['maxitems']               
                  output.write(json.dumps(record))
                  i += 1
        client.upload_file('/tmp/out.json.gz', bucket,newKey)
        return "success"

    except Exception as e:
        print(e)
        print('Error processing object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(newKey, bucket))
        raise e