schtasks /Query /TN Hermes_Gateway /V /FO LIST 2>$null | Select-String 'Last Run|Status|Task To Run'
