import boto3
import logging
import time
import json

def lambda_handler(event, context):
    message = json.loads(event['Records'][0]['Sns']['Message'])
    instanceId = message["EC2InstanceId"]
    print("instanceId="+instanceId)
    ssmClient = boto3.client('ssm')
    ssmCommand = ssmClient.send_command( 
        InstanceIds = [ instanceId ], 
        DocumentName = 'AWS-RunPowerShellScript', 
        TimeoutSeconds = 270,
        Parameters={'commands': ['.\\remove-application-instance-from-domain.ps1'],
                     "executionTimeout": ['3600'],
                     "workingDirectory": ['D:\\DSC\\dsc-scripts']}
    )

    print(ssmCommand['Command']['CommandId'])
    
    status = ssmCommand['Command']['Status']
    while status == 'Pending' or status == 'InProgress': 
        time.sleep(3)
        status = (ssmClient.list_commands(CommandId=ssmCommand['Command']['CommandId']))['Commands'][0]['Status']

    actionResult = "CONTINUE"
    if (status != 'Success'):
        actionResult = "ABANDON"

    asgClient = boto3.client('autoscaling')
    lifeCycleHook = message['LifecycleHookName']
    autoScalingGroup = message['AutoScalingGroupName']

    response = asgClient.complete_lifecycle_action(
        LifecycleHookName = lifeCycleHook,
        AutoScalingGroupName = autoScalingGroup,
        LifecycleActionResult = actionResult,
        InstanceId = instanceId
    )
    print(json.dumps(response))
    return None