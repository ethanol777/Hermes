schtasks /Query /TN Hermes_Gateway /V /FO LIST 2>$null | Select-String 'Run As User|Task To Run|Hidden|Run Only|Start In'
