schtasks /Query /TN Hermes_Gateway /V /FO LIST 2>$null | Select-String 'TaskName|Status|Schedule Type|Logon Mode|Task To Run|Scheduled Task'
