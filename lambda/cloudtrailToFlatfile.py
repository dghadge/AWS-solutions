from __future__ import print_function
import json
import urllib
import boto3
import gzip
import os
import re
import time
import uuid

s3 = boto3.resource('s3')
client = boto3.client('s3')
glue = boto3.client('glue')


def convertColumntoLowwerCaps(obj):
    for key in obj.keys():
        new_key = re.sub(r'[\W]+', '', key.lower())
        v = obj[key]
        if isinstance(v, dict):
            v['etltimestamp'] = int(time.time())
            if len(v) > 0:
                convertColumntoLowwerCaps(v)
        if new_key != key:
            obj[new_key] = obj[key]
            del obj[key]
    return obj


def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.unquote_plus(
        event['Records'][0]['s3']['object']['key'].encode('utf8'))
    
    if 'CloudTrail_us-east-1' not in key:
        return "success"
    print(bucket)
    print(key)

    try:
        newKey = 'flatfiles/' + "cloudtraillogs" + uuid.uuid4().hex + ".json.gz"        
        client.download_file(bucket, key, '/tmp/file.json.gz')
        with gzip.open('/tmp/out.json.gz', 'w') as output, gzip.open('/tmp/file.json.gz', 'rb') as file:
            i = 0
            for line in file:
                print(line)
                for record in json.loads(line, object_hook=convertColumntoLowwerCaps)['records']:
                    if i != 0:
                        output.write("\n")
                    if 'responseelements' in record and record['responseelements'] != None and 'version' in record['responseelements']:
                        del record['responseelements']['version']
                    if 'requestparameters' in record and record['requestparameters'] != None and 'maxitems' in record['requestparameters']:
                        del record['requestparameters']['maxitems']
                    output.write(json.dumps(record))
                    i += 1
        client.upload_file('/tmp/out.json.gz', bucket, newKey)
        return "success"
    except Exception as e:
        print(e)
        raise e
    return "success"