# Automated Solution to Reduce Cost
AWS Trusted Advisor help you reduce cost, increase performance, and improve security by optimizing your AWS environment. Trusted Advisor provides real time guidance to help you provision your resources following AWS best practices.

![alt text](https://github.com/InformaFI/AWSMigration/blob/master/apps/trustedAdvisor/Trusted_Advisor.png)

This application/cloudformation automates the cost recommendations given by Trusted Advisor and can easily be extended to security or other best practice recommendations provided by Trusted Advisor. 

Architecture wise - this solution uses CloudWatch events in response to Trusted Advisor findings to invoke lambda function which then takes appropriate actions detailed below.

### 1. Low Utilization Amazon EC2 Instances.
       Handles EC2 instances which have low cpu utilization (<10% cpu utilization)
       Tags EC2 instances with Name=Schedule and Value=stopped 
       EC2 instance scheduler then picks these instances and stops. 
       Dev teams can apply schedule of their choice to start/stop instances. 
       More details on how to do this at : https://github.com/InformaFI/AWSMigration/tree/master/apps/scheduler

### 2. Amazon RDS Idle DB Instances. 
       Handles RDS instances which did not have any connection for more than 7 days.
       Similar to EC2 instances applies tags Name=Schedule and Value=stopped which lets scheduler stops these RDS instances. 

### 3. Underutilized Amazon EBS Volumes.
       Handles underutilized EBS volumes i.e. volumes that are in available state.
       First takes a snapshot of EBS volumes in "available" state and then deletes the volumes.

### 4. Unassociated Elastic IP Addresses.
       Handles EIPs that are not associated with a running EC2 instance by releasing those addresses.
