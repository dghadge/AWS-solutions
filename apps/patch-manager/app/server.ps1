Write-Host 'Script to create an EC2 instance from AMI name?'

$AMIName = Read-Host 'What is the AMI name?'

$AMIID=aws ec2 describe-images --filters "Name=description, Values=*$AMIName*" --query "Images[0].ImageId" --output text
Write-Host "Found AMIID=[$AMIID]"

$VPCID=aws ec2 describe-vpcs --filter "Name=isDefault, Values=false" --query "Vpcs[0].VpcId" --output text

Write-Host 'In which subnet you want to create this EC2?
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

Write-Host "SGIDs=[$SGID]"

$INSTANCEID=aws ec2 run-instances --image-id $AMIID `
            --key-name danghadge-fidev-useast-1 `
            --instance-type t2.micro `
            --tag-specifications 'ResourceType=instance,Tags=[{Key=Application,Value=Profile-Producer}, {Key=Environment,Value=Development}, {Key=Name,Value=PP-WS}]' `
            --security-group-ids $SGID `
            --subnet-id $SUBNETID `
            --query "Instances[0].InstanceId" `
            --output text
Write-Host "waiting for instance $INSTANCEID ..."
aws ec2 wait instance-running --instance-ids $INSTANCEID
$PUBLICNAME=aws ec2 describe-instances --instance-ids $INSTANCEID --query "Reservations[0].Instances[0].PublicDnsName" --output text

Write-Host "InstanceID $INSTANCEID $PUBLICBAME is now accepting connections."

Write-Host "done."