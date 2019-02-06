# Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
# http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.

<#
.SYNOPSIS
        
    Initializes disks attached to your EC2 instance. 

.DESCRIPTION
    You must set any services that depend on Instance Storage to delayed start so this script
    has an opportunity to initialize the Instance Storage drive and permission it.

#>
param (
    [parameter(Mandatory=$false)]
    [switch] $EnableTrim
)

Set-Variable rootPath -Option Constant -Scope Local -Value (Join-Path $env:ProgramData -ChildPath "Amazon\EC2-Windows\Launch")
Set-Variable modulePath -Option Constant -Scope Local -Value (Join-Path $rootPath -ChildPath "Module\Ec2Launch.psd1")
Set-Variable scriptPath -Option Constant -Scope Local -Value (Join-Path $PSScriptRoot -ChildPath $MyInvocation.MyCommand.Name)
Set-Variable scheduleName -Option Constant -Scope Local -Value "Disk Initialization" 
Set-Variable shellHwRegPath -Option Constant -Scope Local -Value "HKLM:\SYSTEM\CurrentControlSet\services\ShellHWDetection"

# Import Ec2Launch module to prepare to use helper functions.
Import-Module $modulePath

# Before calling any function, initialize the log with filename
Initialize-Log -Filename "DiskInitialization.log"

try 
{    
    Write-Log "Initializing disks started"
    
    # Set TRIM using settings value from userdata.
    # By default, TRIM is disabled before formatting disk.
    $wasTrimEnabled = Set-Trim -Enable $EnableTrim

    # Check if system is using Citrix's PV driver.
    $citrixPv = Get-CimInstance -ClassName Win32_PnPEntity -Filter "Service='xenvbd'"
    $usingCitrixPv = $citrixPv -and $citrixPv.Length -ne 0
    
    # This count is used to label ephemeral disks.
    $ephemeralCount = 0
    
    $allSucceeded = $true

    # Retrieve and initialize each disk drive.
    foreach ($disk in (Get-CimInstance -ClassName Win32_DiskDrive)) 
    {
        Write-Log ("Found Disk Name:{0}; Index:{1}; SizeBytes:{2};" -f $disk.Name, $disk.Index, $disk.Size)
        
        # Disk must not be set to readonly.
        Set-Disk -Number $disk.Index -IsReadonly $False -ErrorAction SilentlyContinue | Out-Null

        # Check if a partition is available for the disk.
        # If no partition is found for the disk, we need to create a new partition.
        $partitioned = Get-Partition $disk.Index -ErrorAction SilentlyContinue

        # Find out if the disk is whether ephemeral or not.
        $isEphemeral = $false
        $currentDriveRootPath = ''

        if($usingCitrixPv)
        {
            $isEphemeral = Test-EphemeralDisk -DiskIndex $disk.Index -DiskSCSITargetId $disk.SCSITargetId
        }

        
        if ($partitioned)
        {
            Write-Log ("Partition already exists: PartitionNumber {0}; DriverLetter {1}" -f $partitioned.PartitionNumber, $partitioned.DriveLetter)
            $currentDriveRootPath = "$($partitioned.DriveLetter):\"
        }
        else
        {
            # Finally, set the disk and get drive letter for result.
            # If disk is ephemeral, label the disk.
            $driveLetter = Initialize-Ec2Disk -DiskIndex $disk.Index -EphemeralCount $ephemeralCount -IsEphemeral $isEphemeral

            # If disk is successfully loaded, driver letter should be assigned.
            if ($driveLetter)
            {
                # If it was ephemeral, increment the ephemeral count and create a warning file.
                if ($isEphemeral)
                {
                    New-WarningFile -DriveLetter $driveLetter
                    $currentDriveRootPath = "$($driveLetter):\"
                }
            }
            else 
            {
                # If any disk failed to be initilaized, exitcode needs to be 1. 
                $allSucceeded = $false
            }
        }

        if ($isEphemeral)
        {
            $ephemeralCount++

            Write-Log "Setting permissions on ephemeral drive $($currentDriveRootPath)"

            #  Grant Everyone full access to the new drive
            $Acl = (Get-Item $currentDriveRootPath).GetAccessControl('Access')
            $Username = 'Everyone'
            $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
            $Acl.SetAccessRule($Ar)
            Set-Acl -path $currentDriveRootPath -AclObject $Acl
        }
    }

    if ($allSucceeded)
    {
        Write-Log "Initializing disks done successfully"
        Exit 0
    }
    else
    {
        Write-Log "Initializing disks done, but with at least one disk failure"
        Exit 1
    }
}
catch 
{
    Write-Log ("Failed to initialize drives: {0}" -f $_.Exception.Message)
    Exit 1
}
finally
{
    # If TRIM was originally enabled, make sure TRIM is set to be enabled.
    Set-Trim -Enable $wasTrimEnabled | Out-Null

    # Before finishing the script, complete the log.
    Complete-Log
}
