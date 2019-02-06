# PIQ Migration
###  Specific implementation of elastic beanstalk extentions for PIQ migration

###  Important files and purpose
#####  1. as-hook.config
       Auto Scaling hook which removes instance from AD domain before intance termination
       Uses SNS/SES to trigger Cloudwatch event which in-turn invokes lambda. 
       The lambda uses systems manager run command to run powershell script 
       which removes the instance from AD
#####  2. privatekey.config
       Creates S3 Authentication Resource "s3auth" using Cloudformation. 
       Using "s3auth" beanstalk can download powershell scripts zip file and 
       unzip on encrypted drive D:\
#####  3. ws-instance.config and mt-intance.config
       WebServer(ws) and MiddleTier(mt) config files to download and run powershell scripts
