# PIQ Migration
###  Specific implementation of elastic beanstalk cloudformation template for PIQ migration
      
###  Following are the important resources created
#####  1. Elastic beanstalk application. 
          Set parameter CreateApplication to "true"
#####  2. Elastic beanstalk environment
          Consists of 2 EC2 instances load balanced in 2 separate AZ(s)
          For ws instances are created in public subnet and 
          for mt instances are created in private subnet
#####  3. Application Load Balancer (ALB)
          Internal ALB is created in DMZ subnet. It uses certificate from ACM 
          and routes traffic to target groups consisting of EC2 instances
#####  4. Route53 A-Records
          PIQ uses DNS header match to serve appropriate website. 
          PIQ will reject traffic if header records don't match.
          Ensure A-Records are named appropriately in parameters 
          so they match the header requirements in PIQ. 


#####  Some other important considerations
       * This cloudformation/beanstalk downloads application code and 
         powershell scripts to specific encrupted drive on EC2. 
         As a result packaging application code with proper ebextensions is critical. 
         Specifically ensure ebextensions to unencrpt downloaded source 
         packages are included in source package.
       * This cloudformation/beanstalk template uses custom AMI. 
         However its important to use elastic beanstalk base image and add 
         customizations to the base image.  
       * Use parameter "EC2NewName" to rename the EC2 instance created. 
         Else the name of EC2 instance will be same as environment name.

          
                    
