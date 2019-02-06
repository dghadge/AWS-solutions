# Initialize Instance Storage
###  Overview
On Windows Server 2016 instances, Instance Storage (ephemeral) volumes are not initialized when the instance boots. This script initializes and mounts all Instance Storage (ephemeral) volumes attached to an instance as a single drive each time the instance boots.

###  Usage
1. Copy the folder to the C Drive of the windows EC2 instance
2. Edit InitializeInstanceStorage.ps1, setting the $DriveLetterToAssign variable to the drive letter the instance storage volume(s) should be mounted on. The default is Z:\\.
2. Open Task Scheduler and import Initialize Instance Storage.xml to create the scheduled task that runs the ps1 at startup
3. Reboot the instance to verify the setup