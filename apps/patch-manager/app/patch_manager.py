import os
import sys
import boto3
import json
from collections import defaultdict
from botocore.exceptions import ClientError

class PatchManager:

    def listInstances(self):
        # Connect to EC2
        ec2 = boto3.resource('ec2')

        # Get information for all running instances
        running_instances = ec2.instances.filter(Filters=[{
            'Name': 'instance-state-name',
            'Values': ['running']}])

        ec2info = defaultdict()
        for instance in running_instances:
            name = ''
            patchgroup = ''
            for tag in instance.tags:
                if 'Name'in tag['Key']:
                    name = tag['Value']
                if 'Patch Group' in tag['Key']:
                    patchgroup = tag['Value']

                # Add instance info to a dictionary
                ec2info[instance.id] = {
                    'Name': name,
                    'Instance ID': instance.id,
                    'Private IP': instance.private_ip_address,
                    'Public IP': instance.public_ip_address,
                    'Patch Group': patchgroup
                }

        attributes = ['Name', 'Instance ID',
                      'Private IP', 'Public IP', 'Patch Group']
        for instance_id, instance in ec2info.items():
            print('\nEC2 Instance :')
            for key in attributes:
                print("\t{0}: {1}".format(key, instance[key]))

    def applyTag(self):
        ec2 = boto3.resource('ec2')
        instanceId = raw_input("InstanceID: ")
        tag = raw_input("Patch Group Tag: ")
        ec2.create_tags(Resources=[instanceId], Tags=[{'Key': 'Patch Group', 'Value': tag}])

    def applyPatch(self):
        ssm = boto3.client('ssm')

        try:
            response = ssm.create_patch_baseline(
                OperatingSystem='WINDOWS',
                Name='Production-Baseline',
                ApprovalRules={
                    'PatchRules': [
                        {
                            'PatchFilterGroup': {
                                'PatchFilters': [
                                    {
                                        'Key': 'MSRC_SEVERITY',
                                        'Values': [
                                            'Critical',
                                            'Important'
                                        ]
                                    },
                                    {
                                        'Key': 'CLASSIFICATION',
                                        'Values': [
                                            'SecurityUpdates',
                                            'Updates',
                                            'UpdateRollups',
                                            'CriticalUpdates'
                                        ]
                                    },
                                ]
                            },
                            'ApproveAfterDays': 7
                        },
                    ]
                },
                Description='Baseline containing all updates approved for production systems'
            )

            pgResponse = ssm.register_patch_baseline_for_patch_group(BaselineId=response['BaselineId'], PatchGroup='Critical')
            pgResponse = ssm.register_patch_baseline_for_patch_group(BaselineId=response['BaselineId'], PatchGroup='Important')
            
            cmwResponse = ssm.create_maintenance_window(   
                Name="Production-Tuesdays", 
                Description="First Tuesday of every month", 
                Schedule="cron(0 0 22 ? * TUE *)",
                Duration=1,
                Cutoff=0,
                AllowUnassociatedTargets=False
            )

            rtwmwResponse = ssm.register_target_with_maintenance_window(
                WindowId=cmwResponse['WindowId'],
                ResourceType='INSTANCE',
                Targets=[{
                    'Key': 'tag:Patch Group',
                    'Values': [
                        'Critical',
                        'Important'
                    ]
                },],
                OwnerInformation='IFI-maintenance',
                Name='MaintenanceWindowTargets',
                Description='Production Tuesdays-First tuesday of every month'
            )

            rtakwmwResponse = ssm.register_task_with_maintenance_window(
                WindowId=cmwResponse['WindowId'],
                Targets=[
                    {
                        'Key': 'WindowTargetIds',
                        'Values': [
                            rtwmwResponse['WindowTargetId']
                        ]
                    },
                ],
                TaskArn='AWS-ApplyPatchBaseline',
                ServiceRoleArn='arn:aws:iam::912667018957:role/patchManagerRole',
                TaskType='RUN_COMMAND',
                TaskParameters={
                    'Operation': {
                        'Values': [
                            'Install',
                        ]
                    }
                },
                MaxConcurrency="1",
                MaxErrors="1",
                Name='IFI-MaintenanceTasks',
                Description='Production Tuesdays-First tuesday of every month'
            )
            print "Registered tasks with maintenance window : ", rtakwmwResponse['WindowTaskId']
        except ClientError as e:
            print "Error Code    : {code}  \nError Message : {msg}".format(code=e.response['Error']['Code'], msg=e.response['Error']['Message'])
                
    def describeCompliance(self):
        try:
            ssm = boto3.client('ssm')

            print "\nPatch Status for Patch Group : Critical"
            pgStatusCritical = ssm.describe_patch_group_state(PatchGroup='Critical')
            print "\tNo of Instances: {instances} \n\tInstalled patches: {installedPatches}\n\tMissing patches: {missingPatches} \n\tFailed patches: {failedPatches}\n\tNot Applicable patches: {naPatches}\n\tOther patches: {otherPatches} ".format(instances=pgStatusCritical['Instances'], 
                        installedPatches=pgStatusCritical['InstancesWithInstalledPatches'], 
                        missingPatches=pgStatusCritical['InstancesWithMissingPatches'], 
                        failedPatches=pgStatusCritical['InstancesWithFailedPatches'], 
                        naPatches=pgStatusCritical['InstancesWithNotApplicablePatches'], 
                        otherPatches=pgStatusCritical['InstancesWithInstalledOtherPatches'] )

            print "\nPatch Status for Patch Group : Important"
            pgStatusImportant = ssm.describe_patch_group_state(PatchGroup='Important')
            print "\tNo of Instances: {instances} \n\tInstalled patches: {installedPatches}\n\tMissing patches: {missingPatches} \n\tFailed patches: {failedPatches}\n\tNot Applicable patches: {naPatches}\n\tOther patches: {otherPatches} ".format(instances=pgStatusImportant['Instances'], 
                        installedPatches=pgStatusImportant['InstancesWithInstalledPatches'], 
                        missingPatches=pgStatusImportant['InstancesWithMissingPatches'], 
                        failedPatches=pgStatusImportant['InstancesWithFailedPatches'], 
                        naPatches=pgStatusImportant['InstancesWithNotApplicablePatches'], 
                        otherPatches=pgStatusImportant['InstancesWithInstalledOtherPatches'] )
        except ClientError as e:
            print "Error Code    : {code}  \nError Message : {msg}".format(code=e.response['Error']['Code'], msg=e.response['Error']['Message'])




