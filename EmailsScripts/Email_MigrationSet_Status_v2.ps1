cls


# Initialize an empty array
$array = @()

$MGMigratedCount =0;
$TotalVMs = 0;
$TotalReplicatedPercent = '0'
$TotalMigratedPercent = '0'
$migstarttime = 0
$migendtime =0

$Wave = "WAVE6b"

$TableData = ""


$SleepSeconds = 2;
$Output = "";

#Note: Handle $Test carefully if set to false emails will go to email-list from database else set to $true
$Test= $true;




$TableData=""
$MGReplicatedCount = 0
$MGMigratedCount = 0
$MGReplicatedTotalVMs = 0
$MGMigratedTotalVMs = 0
$csvUSDataset = Import-Csv -Path "C:\Temp\MGSet_MigStats_data_dummy_US.csv"  -Delimiter "|"
$("US")
ForEach ($US in $csvUSDataset) {



     try {

     $US.MigState.toString().toUPPER()
     if ( $US.MigState.toString().toUPPER() -eq 'MIGRATED') { 
     $MGMigratedCount += $US.Completed
     $MGMigratedTotalVMs += $US.Total}
     elseif ($US.MigState.toString().toUPPER() -eq 'REPLICATED') { 
     $MGReplicatedCount += $US.Completed
     $MGReplicatedTotalVMs += $US.Total}

      $TableData += "<tr><td>" + $US.Location + "</td>"
        $TableData += "<td>" + $US.MobilityGroup + "</td>"
        $TableData += "<td>" + $US.MigState + "</td>"
        $TableData += "<td>" + $US.MigrationPeriod + "</td>"
        $TableData += "<td>" + $US.Completed + "</td>"
        $TableData += "<td>" + $US.Total + "</td>"   
         
        $percent = ($US.Completed/$US.Total).ToString('P')
          $TableData += "<td style='white-space:nowrap;  vertical-align:top;'>" + $percent + "</td>"        
         $TableData += "</tr>"

     }  catch {
                    Write-Host "Failed to send email to $recipient. Error: $_"
                }

  }

$csvDEDataset = Import-Csv -Path "C:\Temp\MGSet_MigStats_data_dummy_DE.csv"  -Delimiter "|"
$("DE")
ForEach ($DE in $csvDEDataset) {



     try {
      $DE.MigState.toString().toUPPER()
     if ( $DE.MigState.toString().toUPPER() -eq 'MIGRATED') { 
     $MGMigratedCount += $DE.Completed
     $MGMigratedTotalVMs += $DE.Total}
     elseif ($DE.MigState.toString().toUPPER() -eq 'REPLICATED') { 
     $MGReplicatedCount += $DE.Completed
     $MGReplicatedTotalVMs += $DE.Total}

      $TableData += "<tr><td>" + $DE.Location + "</td>"
        $TableData += "<td>" + $DE.MobilityGroup + "</td>"
        $TableData += "<td>" + $DE.MigState + "</td>"
        $TableData += "<td>" + $DE.MigrationPeriod + "</td>"
        $TableData += "<td>" + $DE.Completed + "</td>"
        $TableData += "<td>" + $DE.Total + "</td>"  
        
        $percent = ($DE.Completed/$DE.Total).ToString('P')
        $TableData += "<td style='white-space:nowrap;  vertical-align:top;'>" + $percent + "</td>"        
        $TableData += "</tr>"

     }  catch {
                    Write-Host "Failed to send email to $recipient. Error: $_"
                }

  }

  if ( ( $MGReplicatedCount -gt 0) -and   ($MGReplicatedTotalVMs -gt 0))  {  
    $TotalReplicatedPercent = ($MGReplicatedCount/$MGReplicatedTotalVMs).ToString("P")
  }

  if ( ( $MGMigratedCount -gt 0) -and   ($MGMigratedTotalVMs -gt 0))  {  
    $TotalMigratedPercent = ($MGMigratedCount/$MGMigratedTotalVMs).ToString("P")
  }
  
  if (($MGMigratedCount -ge 1)  -and ($MGReplicatedCount -ge 1)) {
  $Summary  = " $MGReplicatedCount of $MGReplicatedTotalVMs Servers have Replicated."
  $Summary  += " $MGMigratedCount of $MGMigratedTotalVMs Servers have migrated."
  
  }elseif (($MGMigratedCount -eq 0)  -and ($MGReplicatedCount -ge 1)) {
  $Summary  = " $MGReplicatedCount of $MGReplicatedTotalVMs Servers have Replicated with $TotalReplicatedPercent of the replication rate."
  
  
  }elseif (($MGMigratedCount -ge 1)  -and ($MGReplicatedCount -eq 0)) {
  
  $Summary  = " $MGMigratedCount of $MGMigratedTotalVMs Servers have migrated with $TotalMigratedPercent of the migration rate."
  
  }
  
  


  
$Query = “ spWaveUnFilledMigratedVMs_Balance '" + $Wave + "'; "
$Query

$Data = Invoke-SQLcmd -ServerInstance BYUS226VXYE -Database "WavesDb" -Query $Query -TrustServerCertificate

$Data

  

  if ( ($MGMigratedCount -ge 1) -or  ($MGReplicatedCount -ge 1) ) {

  # Define SMTP server details
        $smtpServer = "10.190.58.79"  
        $smtpPort = 25  # Common SMTP port for unauthenticated submission

        # Define email details
        $from = "prashanth.garlapally.ext@bayer.com"  
        #$to = @("naresh.yerragunta.ext@bayer.com","prashanth.garlapally.ext@bayer.com","disha.rochlani@bayer.com") 
        $to = @("prashanth.garlapally.ext@bayer.com")

         $CC =  @("prashanth.garlapally.ext@bayer.com","prashanth-kumar.garlapally@capgemini.com", "ranga-kumar.m@capgemini.com", "sudheer.tenali@capgemini.com", "bayeravscloudpmteam.de@capgemini.com")
         $BCC = @("demudu.bojja@capgemini.com","surendra-kumar.kadali@capgemini.com")
         #$BCC = $cc
           
        $subject = "AVS Migration " + $Wave + ": Migration Activity Status."
        $body = "This is a test email to check SMTP functionality from AVS migration project VM."
        $templatePath = "C:\Temp\email\email_MSet_status_notify_v2.html"
        $htmlTemplate = Get-Content -Path $templatePath -Raw
        $htmlTemplate = $htmlTemplate.Replace("##Wave##",$Wave)
        $htmlTemplate = $htmlTemplate.Replace("##StatusData##",$TableData)
        ##Completed## of ##TotalVMs## Servers have been migrated with  ##TotalPercent## of the migration rate.

        $htmlTemplate = $htmlTemplate.Replace("##Completed##",$MGMigratedCount)
        $htmlTemplate = $htmlTemplate.Replace("##TotalVMs##",$TotalVMs)        
        $htmlTemplate = $htmlTemplate.Replace("##TotalPercent##",$TotalPercent)
        $htmlTemplate = $htmlTemplate.Replace("##Summary##",$Summary)
        $body = $htmlTemplate
         if ($Test)  {
                    $subject  = "Test Email:=" + $subject 
                     $CC =  @("prashanth.garlapally.ext@bayer.com","prashanth-kumar.garlapally@capgemini.com")
                     $BCC = $cc
                    }
         try {
                Send-MailMessage -From $from -To $to -CC $CC -BCC $BCC -Subject $subject -Body $body -SmtpServer $smtpServer -Port $smtpPort -BodyAsHtml -Priority High
                $Output= "Migration status email sent successfully to $to @ $(Get-Date)"
                
               # Start-Sleep -s $SleepSeconds
                } catch {
                    Write-Host "Failed to send email to $recipient. Error: $_"
                }
} else {
            
            Write-Host "Zero  servers have been migrated hence no send email has been sent."

}