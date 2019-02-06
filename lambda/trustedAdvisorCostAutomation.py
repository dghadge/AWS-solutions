import boto3
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(trustedAdvisorEvent, context):

    try:
        logger.info(trustedAdvisorEvent)
        eventDetail = trustedAdvisorEvent['detail']
        eventName = eventDetail['check-name'] 

        if eventName == 'Low Utilization Amazon EC2 Instances':
            ec2 = boto3.client('ec2')
            instanceId = eventDetail['check-item-detail']['Instance ID']
            logger.info("Tagging EC2 Instance :"+instanceId)
            ec2.create_tags(Resources=[instanceId], Tags=[{'Key': 'Schedule', 'Value': 'stopped'}])
        
        elif eventName == 'Amazon RDS Idle DB Instances':
            rds = boto3.client('rds')
            rdsInstanceId = eventDetail['resource_id']
            logger.info("Tagging RDS Instance :"+rdsInstanceId)
            rds.add_tags_to_resource(ResourceName=[rdsInstanceId], Tags=[{'Key': 'Schedule', 'Value': 'stopped'}])

        elif eventName == 'Underutilized Amazon EBS Volumes':        
            ec2 = boto3.resource('ec2')
            volumeId = eventDetail['check-item-detail']['Volume ID']
            volume = ec2.Volume(volumeId)
            if  volume.state=='available':
                logger.info("Creating snapshot for volumeId :"+volumeId)
                snapshot = volume.create_snapshot(Description='Snapshot created in response to TrustedAdvisor event')
                snapshot.create_tags(Tags=volume.tags)
                logger.info("Deleting volumeId :"+volumeId)
                volume.delete()

        elif eventName == 'Unassociated Elastic IP Addresses':
            ec2 = boto3.client('ec2')
            unassociatedEIP = eventDetail['check-item-detail']['IP Address']
            addresses = ec2.describe_addresses(PublicIps=[unassociatedEIP])
            eipAllocationId = addresses['Addresses'][0]['AllocationId']
            logger.info("Releasing Elastic IP Address :"+ unassociatedEIP)
            ec2.release_address(AllocationId=eipAllocationId)

        return True
    except Exception as e:
        logger.error('Error: ' + str(e))
        return False
