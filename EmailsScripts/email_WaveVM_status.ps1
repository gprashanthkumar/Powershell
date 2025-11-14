cls
$Data = Invoke-SQLcmd -ServerInstance BYUS226VXYE -Database "WavesDb" -Query “select W.WaveName, M.Server, M.Percentage , MigState, MigStart, MigEndTime, dbo.fnWaveVMEmailData(v.WaveVMID ) as 'Email'
,W.WaveExecutionDate , WaveExecutionEndDate from [dbo].[tblHCXMigation_status_data] M
inner join  tblWaveVM V  on v.VMName = M.server
inner join tblWave W on W.WaveID =  V.WaveID
where M.Batchid = (select Max(BatchID) from  [dbo].[tblHCXMigation_status_data])
and w.WaveName = ltrim(rtrim('Wave-POC')) " -TrustServerCertificate
$Data

$rowCount = $Data | Measure-Object | Select-Object -ExpandProperty Count
$firstrow = $true;



if ($rowCount -gt 0) {
    Write-Output "Rows returned: $rowCount"
} else {
    Write-Output "No rows returned."
}

if( $rowCount.Count -gt 0) {



ForEach ($Row in $Data) {

if ( $firstrow ) {
        $firstrow = $false



        $Row.WaveName
    

        # Define SMTP server details
        $smtpServer = "10.190.58.79"  
        $smtpPort = 25  # Common SMTP port for unauthenticated submission

        # Define email details
        $from = "prashanth.garlapally.ext@bayer.com"  
        #$to = @("naresh.yerragunta.ext@bayer.com","prashanth.garlapally.ext@bayer.com","disha.rochlani@bayer.com") 
        $to = @("prashanth.garlapally.ext@bayer.com")

        $CC = @("prashanth-kumar.garlapally@capgemini.com", "rubina.b.shaikh@capgemini.com","Sudheer.tenali.ext@bayer.com")

        $BCC = @("sudheer.tenali@capgemini.com","prashanth-kumar.garlapally@capgemini.com")
 
        $subject = "AVS Migration ##Wave##: ##Server## Migration status update notification"
        $body = "This is a test email to check SMTP functionality from AVS migration project VM."
        $templatePath = "C:\Temp\email\email_systemStatus_notify.html"
        $htmlTemplate = Get-Content -Path $templatePath -Raw
        $htmlTemplate = $htmlTemplate.Replace("##Wave##",$Row.WaveName)
        $subject = $subject.Replace("##Wave##",$Row.WaveName).Replace("##Server##",$Row.Server)
        $htmlTemplate = $htmlTemplate.Replace("##ExecutionDate##",$Row.WaveExecutionDate.ToString('dd-MMM-yyyy'))
        $htmlTemplate = $htmlTemplate.Replace("##ExecutionEndDate##",$Row.WaveExecutionEndDate.ToString('dd-MMM-yyyy'))

        $htmlTemplate = $htmlTemplate.Replace("##Server##",$Row.Server)
        $htmlTemplate = $htmlTemplate.Replace("##MigStart##",$Row.MigStart)
        $htmlTemplate = $htmlTemplate.Replace("##Percentage##",$Row.Percentage)
        $htmlTemplate = $htmlTemplate.Replace("##Status##",$Row.MigState)
        
        $body = $htmlTemplate

        # Send test emails
        foreach ($recipient in $to) {
            try {
                Send-MailMessage -From $from -To $recipient -CC $CC -BCC $BCC -Subject $subject -Body $body -SmtpServer $smtpServer -Port $smtpPort -BodyAsHtml -Priority High
                Write-Host "Email sent successfully to $recipient"
            } catch {
                Write-Host "Failed to send email to $recipient. Error: $_"
            }
        }
      }
    }
}