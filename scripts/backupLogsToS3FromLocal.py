#!/usr/bin/python

import boto
import boto.s3
import os
import sys
import uuid
from datetime import datetime

# Fill these in - you get them when you sign up for S3
AWS_ACCESS_KEY_ID = os.environ['AWS_ACCESS_KEY_ID']
AWS_SECRET_ACCESS_KEY = os.environ['AWS_SECRET_ACCESS_KEY']
AWS_SESSION_TOKEN = os.environ['AWS_SESSION_TOKEN']
sourceDir = '/tmp/test'
s3bucket = 'danghadgeifi'
destDir = 'dgg'

#max size in bytes before uploading in parts. between 1 and 5 GB recommended
MAX_SIZE = 5000 * 1000 * 1000
#size of parts when uploading in parts
PART_SIZE = 50 * 1000 * 1000

s3conn = boto.s3.connect_to_region('us-east-1',
                     aws_access_key_id=AWS_ACCESS_KEY_ID,
                     aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
                     security_token=AWS_SESSION_TOKEN)

bucket = s3conn.get_bucket(s3bucket)

uploadFileNames = []
for (sourceDir, dirname, filename) in os.walk(sourceDir):
    for file in filename:
        uploadFileNames.append(os.path.join(sourceDir, file))

def percent_cb(complete, total):
    sys.stdout.write('.')
    sys.stdout.flush()

destDir = destDir + datetime.utcnow().strftime("%Y-%m-%d-%H-%M-%S") + "-" + str(uuid.uuid4())
print destDir

for filename in uploadFileNames:
    destpath = destDir + "/" +filename
    print 'Uploading %s to Amazon S3 bucket %s%s' % \
           (filename, s3bucket, destpath)

    filesize = os.path.getsize(filename)
    if filesize > MAX_SIZE:
        print "multipart upload"
        mp = bucket.initiate_multipart_upload(destpath)
        fp = open(filename,'rb')
        fp_num = 0
        while (fp.tell() < filesize):
            fp_num += 1
            print "uploading part %i" %fp_num
            mp.upload_part_from_file(fp, fp_num, cb=percent_cb, num_cb=10, size=PART_SIZE)

        mp.complete_upload()

    else:
        print "singlepart upload"
        k = boto.s3.key.Key(bucket)
        k.key = destpath
        k.set_contents_from_filename(filename,
                cb=percent_cb, num_cb=10)
