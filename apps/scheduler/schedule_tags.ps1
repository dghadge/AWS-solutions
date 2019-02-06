[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True)]
	[string]$application,

	[Parameter(Mandatory=$True)]
	[string]$period
)
#LegalEntity & CostCode are added if they do not exist, modify if they do
#
# this is not working for me, so if someone has AWS Powershell installed and time to investigate, please fix this
#
#(Get-EC2Instance -Filter @( @{name="tag:Application";values="+$application+"})).Instances |
#ForEach-Object -Process
#{
#		New-EC2Tag -Resources $_.InstanceId -Tags @{ Key="Schedule"; Value=‘+$period+’
#		write-output $_.InstanceId + ' Tagged'
#   }
#}

aws ec2 describe-instances --filters "Name=tag:Application,Values=$application" | findstr /i "instanceid" |
foreach {
	$exp = "aws ec2 create-tags --tags Key=LegalEntity,Value=IIS Key=CostCode,Value=US028 Key=Schedule,Value=$period --resources " + $_.split(":")[1].split(",")[0] + " --profile saml";
	write-output $exp;
	invoke-expression $exp
}
