function replace-hostname {
    param ($dirName, $searchPattern, $oldHostName, $newHostName)
    get-childitem $dirName -recurse -include $searchPattern | 
    select -expand fullname |
    foreach {
            (Get-Content $_) -replace $oldHostName, $newHostName |
             Set-Content $_
    }
}

Write-Host 'Which server you want to work on?
Select  1. WebServer
        2. JavaServer
        3. Batch Server 01
        4. Batch Server 02
        5. Batch Server 03
        6. Batch Server 04
        7. Batch Server 05
        8. Batch Server 06
        9. DF Server 
        10. CM Server'

$optionSelected = Read-Host 'Your selection'

switch ($optionSelected) {
    1   { 
            #----- Start search/replace for WebServers ----#
            #searchPattern = "*.asp, *.inc, *.txt, *.bak, *.config"
            $searchPattern = "*.inc, *.bak"
            $searchDir = "C:\danghadge\FTP_Root"
            $searchFile = "C:\danghadge\Windows\applicationHost.config"

            #replace web server name
            Write-Host "Replacing WebServer names on WebServer"
            replace-hostname $searchDir $searchPattern uefipsndevws01 mynameisnewwebserver

            #replace java server-1 name
            Write-Host "Replacing JavaServer-1 names on WebServer"
            replace-hostname $searchDir $searchPattern uefipsndevjv01 mynameisnewjavaserver01

            #replace java server-2 name
            Write-Host "Replacing JavaServer-2 names on WebServer"
            replace-hostname $searchDir $searchPattern uefipsndevjv02 mynameisnewjavaserver02

            #replace SQL server IP address
            Write-Host "Replacing SQLServer IP address on WebServer"
            replace-hostname $searchDir $searchPattern 10.178.4.57 99.999.9.99

            #replace file server name
            Write-Host "Replacing FileShare name on WebServer"
            replace-hostname $searchFile $searchPattern uefipsndevfs01 mynameisnewfileserver01
        }
    2   { 
            #----- Start search/replace for JavaServers ----#
            $searchPattern = "*.xml, *.conf"
            $searchDir = "C:\JBM\webserver"

            #replace SQL Server IP address
            Write-Host "Replacing SQLServer IP address on JavaServer"
            replace-hostname c:\JBM\webserver\db.conf $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname c:\JBM\webserver\glassfish4\glassfish\domains\IISDomain\config\domain.xml $searchPattern 10.178.4.57 99.999.9.99
        }
    3   { 
            #----- Start search/replace for UEFIPSNDEVDT01 ----#
            Write-Host "Replacing SQLServer IP address on hostname "$env:COMPUTERNAME
            replace-hostname C:\bill\web_production\vendors\datadeals\datadealsproduction.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\dailystylestimer\dailystylestimer.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\dailystylestimer\dailytopgunsassetflowupdate.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\dailystylestimer\stylesproduction.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\checkproduction.xml $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\lipper\lipperconv.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\MPSN_CWOW\Webproduction.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\russelluniverse\russellUniverse.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\sbmax\sbconversion.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\styles\stylesproduction.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\zephyrpsn\zephyrpsn.ini $searchPattern 10.178.4.57 99.999.9.99
        }
    4   { 
            #----- Start search/replace for UEFIPSNDEVDT02 ----#
            Write-Host "Replacing SQLServer IP address on hostname "$env:COMPUTERNAME
            replace-hostname C:\MPSN_CWOW\MSSmithBarney.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\MPSN_CWOW\Webproduction.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\MPSN_CWOW\Dailyproduction.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\MPSN_CWOW\BarclayProduction.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\GlobalPSNUniverses\GlobalPSNUniverses.ini $searchPattern 10.178.4.57 99.999.9.99
        }
    5   { 
            #----- Start search/replace for UEFIPSNDEVDT03 ----#
            Write-Host "Replacing SQLServer IP address on hostname "$env:COMPUTERNAME
            replace-hostname C:\MPSN_CWOW\MSSmithBarney.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\MPSN_CWOW\Webproduction.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\MPSN_CWOW\Dailyproduction.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\MPSN_CWOW\BarclayProduction.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\GlobalPSNUniverses\GlobalPSNUniverses.ini $searchPattern 10.178.4.57 99.999.9.99
        }
    6   { 
            #----- Start search/replace for UEFIPSNDEVDT04 ----#
            Write-Host "Replacing SQLServer IP address on hostname "$env:COMPUTERNAME
            replace-hostname C:\MPSN_CWOW\Webproduction.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\MPSN_CWOW\Dailyproduction.ini $searchPattern 10.178.4.57 99.999.9.99
        }
    7   { 
            #----- Start search/replace for UEFIPSNDEVDT05 ----#
            Write-Host "Replacing SQLServer IP address on hostname "$env:COMPUTERNAME
            replace-hostname C:\MPSN_CWOW\Webproduction.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\MPSN_CWOW\Dailyproduction.ini $searchPattern 10.178.4.57 99.999.9.99
        }
    8   { 
            #----- Start search/replace for UEFIPSNDEVDT06 ----#
            Write-Host "Replacing SQLServer IP address on hostname "$env:COMPUTERNAME
            replace-hostname C:\MPSN_CWOW\Webproduction.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\MPSN_CWOW\Dailyproduction.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\MPSN_CWOW\BarclayProduction.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\GlobalPSNUniverses\GlobalPSNUniverses.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\bill\web_production\daily_update.ini $searchPattern 10.178.4.57 99.999.9.99
        }
    9   { 
            #----- Start search/replace for UEFIPSNDEVDF01 ----#
            Write-Host "Replacing SQLServer IP address on hostname "$env:COMPUTERNAME
            replace-hostname D:\checkproduction\checkproduction.xml $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\bill\merrill_lynch_daily\mluniverse.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname D:\bill\web_production\daily_update.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname D:\bill\web_production\web_production.ini $searchPattern 10.178.4.57 99.999.9.99
        }
    10  {
            #----- Start search/replace for UEFIPSNDEVECM1 ----#
            Write-Host "Replacing SQLServer IP address on hostname "$env:COMPUTERNAME
            replace-hostname C:\newmgr\newmanagerReport2013.ini $searchPattern 10.178.4.57 99.999.9.99
            replace-hostname C:\uploadtoecms\uploadtoecms.xml $searchPattern 10.178.4.57 99.999.9.99
        }
}
Write-Host 'Completed....'
