cls


$Wave = "Wave30"
# Initialize an empty array
$array = @()

$MGMigratedCount =0;
$TotalVMs = 0;
$TotalReplicatedPercent = '0'
$TotalMigratedPercent = '0'
$migstarttime = 0
$migendtime =0
$statsCompleted = 0;
$statsoutstanding = 0;
$statsMigrating = 0;
#Note: Handle $Test carefully if set to false emails will go to email-list from database else set to $true
$Test= $false;



$SleepSeconds = 2;
$Output = "";
$TableData = ""
$TableData= ""
$StatsData = ""
$MGReplicatedCount = 0
$MGMigratedCount = 0
$MGReplicatedTotalVMs = 0
$MGMigratedTotalVMs = 0
$csvUSDataset = Import-Csv -Path "C:\Temp\MGSet_MigStats_data_dummy_US.csv"  -Delimiter "|"
$csvUSDataset = $csvUSDataset | Add-Member -MemberType NoteProperty -Name Percentage -Value $($(0.00) -as [float]) -PassThru

ForEach ($US in $csvUSDataset) {
$comp = [float]$US.Completed
$tot = [float]$US.Total

    if ( ($comp -gt 0) -and  ($tot -gt 0)) {
        $US.Percentage = [float] $([float] $comp/ [float] $tot)
    }
}

$csvUSDataset = $csvUSDataset | Sort-Object  { [float]$_.Percentage }
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
       $bgcolor  = ""
        if ($US.Percentage -eq 0)
        {
        $bgcolor  = "background-color:#ff3f00;"
        $bgcolor  = "background-color:#FFE2E9;"
        }
        $TableData += "<td style='white-space:nowrap;  vertical-align:top; " + $bgcolor +" '>" + $US.MobilityGroup + "</td>"
        $TableData += "<td>" + $US.MigState + "</td>"
        $TableData += "<td>" + $US.MigrationPeriod + "</td>"       
        $TableData += "<td style='white-space:nowrap;  vertical-align:top; " + $bgcolor +" '>" + $US.Completed + "</td>"
        $TableData += "<td>" + $US.Total + "</td>"   
         
        #$percent = ($US.Completed/$US.Total).ToString('P')
        $bgcolor  = ""
        if ($US.Percentage -ge 1)
        {
			if ( $US.MigState.toString().toUPPER() -eq 'MIGRATED') { 
				$bgcolor  = "background-color:#ccffcc;"
			}
			elseif ($US.MigState.toString().toUPPER() -eq 'REPLICATED') { 
			$bgcolor  = "background-color:#edbd07;"
			 
			}
        
        }
        
        $percent = ($US.Percentage).ToString('P')
          $TableData += "<td style='white-space:nowrap;  vertical-align:top; " + $bgcolor +" '>" + $percent + "</td>"        
         $TableData += "</tr>"

     }  catch {
                    Write-Host "Failed to send email to $recipient. Error: $_"
                }

  }

$csvDEDataset = Import-Csv -Path "C:\Temp\MGSet_MigStats_data_dummy_DE.csv"  -Delimiter "|"
$csvDEDataset = $csvDEDataset | Add-Member -MemberType NoteProperty -Name Percentage -Value $($(0.00) -as [float]) -PassThru

ForEach ($de in $csvDEDataset) {
$comp = [float]$de.Completed
$tot = [float]$de.Total

    if ( ($comp -gt 0) -and  ($tot -gt 0)) {  

        $de.Percentage = [float] $([float] $comp/[float] $tot)
    }
}
$csvDEDataset = $csvDEDataset | Sort-Object  { [float]$_.Percentage }


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
         $bgcolor  = ""
      if ($DE.Percentage -eq 0)
        {
        $bgcolor  = "background-color:#ff3f00;"
        $bgcolor  = "background-color:#FFE2E9;"
        }
        $TableData += "<td style='white-space:nowrap;  vertical-align:top;  " + $bgcolor +" '>" + $DE.MobilityGroup + "</td>"
        $TableData += "<td>" + $DE.MigState + "</td>"
        $TableData += "<td>" + $DE.MigrationPeriod + "</td>"      
       
        $TableData += "<td style='white-space:nowrap;  vertical-align:top;  " + $bgcolor +" '>" + $DE.Completed + "</td>"
        $TableData += "<td>" + $DE.Total + "</td>"  
        
        #$percent = ($DE.Completed/$DE.Total).ToString('P')
        $bgcolor  = ""
        if ($DE.Percentage -ge 1)
        {
			
				if ( $DE.MigState.toString().toUPPER() -eq 'MIGRATED') { 
					$bgcolor  = "background-color:#ccffcc;"
				}
				elseif ($DE.MigState.toString().toUPPER() -eq 'REPLICATED') { 
				$bgcolor  = "background-color:#edbd07;"
				 
				}
			
			
        }
        $percent = ($DE.Percentage).ToString('P')
        $TableData += "<td style='white-space:nowrap;  vertical-align:top;  " + $bgcolor +" '>" + $percent + "</td>"        
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
$rowCount = $Data | Measure-Object | Select-Object -ExpandProperty Count

if( $rowCount.Count -ge 0) {

        ForEach ($Row in $Data) {
         $StatsData += "<tr><td>" + $Row.appgroup + "</td>"
         $StatsData += "<td>" + $Row.Completed + "</td>"
         $StatsData += "<td>" + $Row.OutStanding + "</td>"
         $StatsData += "<td>" + $Row.NotMigrating + "</td>"
         $StatsData += "<td>" + $Row.Migrating + "</td>"
         $StatsData += "<td>" + $Row.SubTotal + "</td>"
         
          $percent= ($Row.Completed/$Row.Migrating).ToString('P')
         
         
          $StatsData += "<td style='white-space:nowrap;  vertical-align:top;'>" + $percent + "</td>"   
          $StatsData +="</tr>"
          $statsCompleted += $Row.Completed;
          $statsoutstanding +=  $Row.OutStanding
          $statsMigrating += $Row.Migrating
        }

         $StatsData += "<tr><td>&nbsp;</td>"
         $StatsData += "<td>" + $statsCompleted  + "</td>"
         $StatsData += "<td>" + $statsoutstanding + "</td>"
         $StatsData += "<td>&nbsp;</td>"
         $StatsData += "<td>" + $statsMigrating+ "</td>"
         $StatsData += "<td>&nbsp;</td>"
          
          $StatsData += "<td>&nbsp;</td>"   
          $StatsData +="</tr>"


}

  

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
        $templatePath = "C:\Temp\email\email_MSet_status_notify_v3.html"
        $htmlTemplate = Get-Content -Path $templatePath -Raw
        $htmlTemplate = $htmlTemplate.Replace("##Wave##",$Wave)
        $htmlTemplate = $htmlTemplate.Replace("##StatusData##",$TableData)
        $htmlTemplate = $htmlTemplate.Replace("##StatsData##",$StatsData)
        
        ##Completed## of ##TotalVMs## Servers have been migrated with  ##TotalPercent## of the migration rate.

        $htmlTemplate = $htmlTemplate.Replace("##Completed##",$MGMigratedCount)
        $htmlTemplate = $htmlTemplate.Replace("##TotalVMs##",$TotalVMs)        
        $htmlTemplate = $htmlTemplate.Replace("##TotalPercent##",$TotalPercent)
        $htmlTemplate = $htmlTemplate.Replace("##Summary##",$Summary)
        $body = $htmlTemplate
         if ($Test)  {
                    $subject  = "Test Email:=" + $subject 
                     $CC =  @("prashanth.garlapally.ext@bayer.com","prashanth-kumar.garlapally@capgemini.com","phani.adiraju.ext@bayer.com","phani.ramcharan-adiraju@capgemini.com")
                     $BCC = $cc
                    }
         try {
                Send-MailMessage -From $from -To $to -CC $CC -BCC $BCC -Subject $subject -Body $body -SmtpServer $smtpServer -Port $smtpPort -BodyAsHtml -Priority High
                $Output= "Migration status email sent successfully to $to @ $(Get-Date)"
                 Write-Host $Output
                
               # Start-Sleep -s $SleepSeconds
                } catch {
                    Write-Host "Failed to send email to $recipient. Error: $_"
                }
} else {
            
            Write-Host "Zero  servers have been migrated hence no send email has been sent."

}