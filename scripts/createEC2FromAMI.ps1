$envName = Read-Host 'Please enter your environment name'

$AMIName = Read-Host 'Please enter your EC2 AMI name(description)'

$AMIID=aws ec2 describe-images --filters "Name=description, Values=*$AMIName*" --query "Images[0].ImageId" --output text
if($AMIID -eq "None"){
    Write-Host "## Error - Could not find AMI ID for AMI name $AMIName; exiting"    
    return
}
Write-Host "Found AMIID=[$AMIID]"

$VPCID=aws ec2 describe-vpcs --filter "Name=isDefault, Values=false" --query "Vpcs[0].VpcId" --output text

Write-Host 'Please select a subnet in which to create EC2?
Select  1. Private
        2. Public
        3. DMZ'

$optionSelected = Read-Host 'Your selection'

switch ($optionSelected) {
    1   {   
        $SUBNETID=aws ec2 describe-subnets --filters "Name=tag:Name, Values=*private*" --query "Subnets[0].SubnetId" --output text
        Write-Host "Selecting private SubnetID=[$SUBNETID]"
    }
    2   {
        $SUBNETID=aws ec2 describe-subnets --filters "Name=tag:Name, Values=*public*" --query "Subnets[0].SubnetId" --output text
        Write-Host "Selecting public SubnetID=[$SUBNETID]"
    }
    3   {
        $SUBNETID=aws ec2 describe-subnets --filters "Name=tag:Name, Values=*dmz*" --query "Subnets[0].SubnetId" --output text
        Write-Host "Selecting DMZ SubnetID=[$SUBNETID]"
    }
}

$SGID=aws ec2 describe-security-groups --filters "Name=tag:Purpose, Values=Enterprise Security" --query "SecurityGroups[0].GroupId" --output text
$SGID=$SGID.replace("`t", " ")

Write-Host "EC2 is using Security Groups [$SGID]"

$INSTANCEID=aws ec2 run-instances --image-id $AMIID `
            --key-name danghadge-fidev-useast-1 `
            --instance-type t2.micro `
            --tag-specifications "ResourceType=instance,Tags=[{Key=Application,Value=$appName}, {Key=Environment,Value=$envName}, {Key=Name,Value=$AMIName}]" `
            --security-group-ids $SGID `
            --subnet-id $SUBNETID `
            --query "Instances[0].InstanceId" `
            --output text
Write-Host "Waiting for instance $INSTANCEID to come online..."
aws ec2 wait instance-running --instance-ids $INSTANCEID
$PUBLICNAME=aws ec2 describe-instances --instance-ids $INSTANCEID --query "Reservations[0].Instances[0].PublicDnsName" --output text

Write-Host "InstanceID $INSTANCEID $PUBLICBAME is now accepting connections."

return $INSTANCEID