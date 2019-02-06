# Workflow to schedule resources

## 1. Check if any existing periods work for you.
    scheduler-cli describe-periods --stack Scheduler

## 2. Create periods.
    scheduler-cli create-period --name "nashville-nonwednesdays" --begintime 07:00 --endtime 18:00 --weekdays "mon,tue,thu,fri" --description "Nashville office hours except wednesdays" --stack Scheduler

    scheduler-cli create-period --name "nashville-wednesdays" --begintime 07:00 --endtime 22:00 --weekdays "wed" --description "Nashville office hours on wednesdays"   --stack Scheduler

    scheduler-cli create-period --name wp-office-hours --begintime 07:00 --endtime 19:00 --weekdays "mon-fri" --description "WP Weekday Office Hours" --stack Scheduler


## 3. Ensure periods are created as expected
    scheduler-cli describe-periods --stack Scheduler

## 4. Create schedules
    scheduler-cli create-schedule --name nashville-web-office-hours --periods nashville-nonwednesdays,nashville-wednesdays --timezone US/Central --stack Scheduler

    scheduler-cli create-schedule --name wp-office-hours-schedule --periods wp-office-hours --timezone US/Eastern --stack Scheduler

## 5. Ensure schedule is created as expected
    scheduler-cli describe-schedules --stack Scheduler

## 6. Apply tag to resources.
    For this example tag-name="Schedule" tag-value="nashville-web-office-hours"

## 7. Bulk apply tag to EC2 Instances (note that it also applies CostCode and LegalEntity if they do not exist on the EC2 instance)
    .\schedule_tags.ps1 -application PIQ -period nashville-web-office-hours

    .\schedule_tags.ps1 -application CSIQ -period wp-office-hours

## 8. To keep STOPPED instances in their stopped state
    For this example tag-name="Schedule" tag-value="stopped"
