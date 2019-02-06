Write-Host '### Creating application infrastructure ###'

$appName = Read-Host 'Please enter your application name'

$instanceID = & ((Split-Path $MyInvocation.InvocationName) + "\createEC2FromAMI.ps1") $appName

if(!$instanceID) {
    return
}

Write-Host '### Creating ELB and Route53 A-Record ###'

$certARN = aws acm list-certificates --query "CertificateSummaryList[?DomainName=='*.op.informais.com'].CertificateArn" --output text
$dmzSubnetA = aws ec2 describe-subnets --filters "Name=tag:Name, Values=*DMZSubnet_a*" --query "Subnets[].SubnetId" --output text
$dmzSubnetB = aws ec2 describe-subnets --filters "Name=tag:Name, Values=*DMZSubnet_b*" --query "Subnets[].SubnetId" --output text
$dmzSubnetC = aws ec2 describe-subnets --filters "Name=tag:Name, Values=*DMZSubnet_c*" --query "Subnets[].SubnetId" --output text

$vpcID = aws ec2 describe-vpcs --filter "Name=isDefault, Values=false" --query "Vpcs[].VpcId" --output text

$sgID = aws ec2 describe-security-groups --filters "Name=group-name,Values=Allow-http-https" --query "SecurityGroups[0].GroupId" --output text
if (!$sgID) {
    $sgID = aws ec2 create-security-group --description "ELB Security Group. Allows 80 & 443" --group-name "Allow-http-https" --vpc-id $vpcID
    aws ec2 authorize-security-group-ingress --group-id $sgID --protocol tcp --port 80 --cidr 0.0.0.0/0 
    aws ec2 authorize-security-group-ingress --group-id $sgID --protocol tcp --port 443 --cidr 0.0.0.0/0 
}

$hzID = aws route53 list-hosted-zones --query "HostedZones[?Name=='op.informais.com.'].Id" --output text
$hzID = $hzID.SubString($hzID.LastIndexOf('/')+1)

$lbARN = aws elbv2 create-load-balancer `
--name $appName `
--subnets $dmzSubnetA $dmzSubnetB $dmzSubnetC `
--security-groups $sgID `
--scheme internet-facing `
--type application `
--query "LoadBalancers[].LoadBalancerArn" `
--output text

$lbDNS = aws elbv2 describe-load-balancers --load-balancer-arns $lbARN --query "LoadBalancers[].DNSName" --output text
$lbHzID = aws elbv2 describe-load-balancers --load-balancer-arns $lbARN --query "LoadBalancers[].CanonicalHostedZoneId" --output text

$tgARN = aws elbv2 create-target-group `
--name $appName `
--protocol HTTPS `
--port 443 `
--vpc-id $vpcID `
--query "TargetGroups[].TargetGroupArn" `
--output text

$devnull = aws elbv2 register-targets `
--targets Id=$instanceID `
--target-group-arn=$tgARN `
--output text

$devnull = aws elbv2 create-listener `
--load-balancer-arn  $lbARN `
--protocol HTTPS --port 443 `
--certificates CertificateArn=$CertArn `
--ssl-policy ELBSecurityPolicy-2016-08 `
--default-actions Type=forward,TargetGroupArn=$tgARN `
--output text

$devnull = aws elbv2 create-listener `
--load-balancer-arn $lbARN `
--protocol HTTP --port 80 `
--default-actions Type=forward,TargetGroupArn=$tgARN `
--output text

$recordName = "$appName.op.informais.com."

$r53JSON = "{
    \""HostedZoneId\"": \""$hzID\"",
    \""ChangeBatch\"": {
        \""Comment\"": \""A Record Alias for app name: $appName with DNS:$lbDNS\"",
        \""Changes\"": [{
            \""Action\"": \""CREATE\"",
            \""ResourceRecordSet\"": {
                \""Name\"": \""$recordName\"",
                \""Type\"": \""A\"",
                \""AliasTarget\"": {
                    \""HostedZoneId\"": \""$lbHzID\"",
                    \""DNSName\"": \""$lbDNS\"",
                    \""EvaluateTargetHealth\"": true                    
                } 
            } 
        }]
    }
}".Replace("`r`n", "")

$rsRsp = aws route53 list-resource-record-sets  `
--hosted-zone-id $hzID `
--query "ResourceRecordSets[?Name == '$recordName']" `
--output text

if(!$rsRsp) {
    $devnull = aws route53 change-resource-record-sets --cli-input-json "$r53JSON"
}

Write-Host "Application URL: https://$appName.op.informais.com"