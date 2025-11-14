cls


# Initialize an empty array
$array = @()
$Location  = "US"
$MGMigratedCount =0;
$TotalVMs = 0;
$TotalPercent = '0'
$migstarttime = 0
$migendtime =0

$Wave = "Wave5"
$Wavefolder = $Wave.Replace(" ","_");
$MGSets = Get-Content -Path "C:\Temp\$Wavefolder\Wave-MGSet.txt"

$TableData = ""


$SleepSeconds = 2;
$Output = "";

#Note: Handle $Test carefully if set to false emails will go to email-list from database else set to $true
$Test= $true;




$TableData=""
$MGMigratedCount = 0
$TotalVMs = 0
$csvUSDataset = Import-Csv -Path "C:\Temp\MGSet_MigStats_data_dummy_US.csv"  -Delimiter "|"
ForEach ($US in $csvUSDataset) {



     try {
     $MGMigratedCount += $US.Completed
     $TotalVMs += $US.Total

      $TableData += "<tr><td>" + $US.Location + "</td>"
        $TableData += "<td>" + $US.MobilityGroup + "</td>"
        $TableData += "<td>" + $US.MigState + "</td>"
        $TableData += "<td>" + $US.MigrationPeriod + "</td>"
        $TableData += "<td>" + $US.Completed + "</td>"
        $TableData += "<td>" + $US.Total + "</td>"        
         $TableData += "</tr>"

     }  catch {
                    Write-Host "Failed to send email to $recipient. Error: $_"
                }

  }

$csvDEDataset = Import-Csv -Path "C:\Temp\MGSet_MigStats_data_dummy_DE.csv"  -Delimiter "|"
ForEach ($DE in $csvDEDataset) {



     try {
      $MGMigratedCount += $DE.Completed
     $TotalVMs += $DE.Total

      $TableData += "<tr><td>" + $DE.Location + "</td>"
        $TableData += "<td>" + $DE.MobilityGroup + "</td>"
        $TableData += "<td>" + $DE.MigState + "</td>"
        $TableData += "<td>" + $DE.MigrationPeriod + "</td>"
        $TableData += "<td>" + $DE.Completed + "</td>"
        $TableData += "<td>" + $DE.Total + "</td>"        
         $TableData += "</tr>"

     }  catch {
                    Write-Host "Failed to send email to $recipient. Error: $_"
                }

  }
  if ( ( $TotalPercent -ge 0) -and   ($TotalVMs -ge 0))  {
  
    $TotalPercent = ($MGMigratedCount/$TotalVMs).ToString("P")
    

  }
  $TotalPercent

  if ($MGMigratedCount -ge 1) {

  # Define SMTP server details
        $smtpServer = "10.190.58.79"  
        $smtpPort = 25  # Common SMTP port for unauthenticated submission

        # Define email details
        $from = "prashanth.garlapally.ext@bayer.com"  
        #$to = @("naresh.yerragunta.ext@bayer.com","prashanth.garlapally.ext@bayer.com","disha.rochlani@bayer.com") 
        $to = @("prashanth.garlapally.ext@bayer.com")

         $CC =  @("prashanth.garlapally.ext@bayer.com","prashanth-kumar.garlapally@capgemini.com", "ranga-kumar.m@capgemini.com", "sudheer.tenali@capgemini.com")
         $BCC = @("demudu.bojja@capgemini.com","surendra-kumar.kadali@capgemini.com")
         #$BCC = $cc
           
        $subject = "AVS Migration " + $Wave + ": Migration Activity Status."
        $body = "This is a test email to check SMTP functionality from AVS migration project VM."
        $templatePath = "C:\Temp\email\email_MSet_status_notify_v2.html"
        $htmlTemplate = Get-Content -Path $templatePath -Raw
        $htmlTemplate = $htmlTemplate.Replace("##Wave##",$Wave)
        $htmlTemplate = $htmlTemplate.Replace("##StatusData##",$TableData)

        $htmlTemplate = $htmlTemplate.Replace("##Completed##",$MGMigratedCount)
        $htmlTemplate = $htmlTemplate.Replace("##TotalVMs##",$TotalVMs)        
        $htmlTemplate = $htmlTemplate.Replace("##TotalPercent##",$TotalPercent)
        $body = $htmlTemplate
         if ($Test)  {
                    $subject  = "Test Email:=" + $subject 
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