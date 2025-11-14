cls
$Data = Invoke-SQLCmd -ServerInstance BYUS226VXYE -Database "WavesDb" -Query “select * from tblWave where waveID = 2; " -TrustServerCertificate
$Data


$rowCount = $Data | Measure-Object | Select-Object -ExpandProperty Count



if ($rowCount -gt 0) {
    Write-Output "Rows returned: $rowCount"
} else {
    Write-Output "No rows returned."
}

if( $rowCount.Count -gt 0) {

    $Data.WaveName
    

    # Define SMTP server details
    $smtpServer = "10.190.58.79"  
    $smtpPort = 25  # Common SMTP port for unauthenticated submission

    # Define email details
    $from = "prashanth.garlapally.ext@bayer.com"  
    #$to = @("naresh.yerragunta.ext@bayer.com","prashanth.garlapally.ext@bayer.com","disha.rochlani@bayer.com") 
    $to = @("pablo.damico@bayer.com") 
    <#$to = @("prashanth.garlapally.ext@bayer.com")#>

    
    
    $CC = @("christian.billig@bayer.com"
    ,"pablo.damico@bayer.com"
    ,"stefan.schreiber@bayer.com"
    ,"jan.meineke@bayer.com"
    ,"heloisa.kronemberger@bayer.com"
    ,"henrik.breitenstein@bayer.com"
    ,"Ewa.Fernandez@microsoft.com"
    ,"daniel.knobloch@microsoft.com"
    ,"kholubova@microsoft.com"
    ,"volkern@microsoft.com"
    ,"pamela.salvatori@microsoft.com"
    ,"Michael.Stummvoll@microsoft.com"
    ,"Pooja.Punjabi@microsoft.com"
    ,"bmalter@microsoft.com"
    ,"Ramon.diegel@microsoft.com"
    ,"hrdeepthi@microsoft.com"
    ,"bayeravscloudprojectteam.de@capgemini.com"
    ,"guilherme.viggiani@bayer.com"
    )
    <#
    $CC = @("skadali@capgemini.com", "rubina.b.shaikh@capgemini.com")
    #>
    $BCC = @("prashanth.garlapally.ext@bayer.com","prashanth-kumar.garlapally@capgemini.com")
    
    <#$CC = @("prashanth-kumar.garlapally@capgemini.com", "rubina.b.shaikh@capgemini.com")#>
 
    $subject = "AVS Migration Project: Migration ##Wave## - Notification"
    $body = "This is a test email to check SMTP functionality from apptestpopapp2 VM."
    $templatePath = "C:\Temp\email\email_notify.html"
    $htmlTemplate = Get-Content -Path $templatePath -Raw
    $htmlTemplate = $htmlTemplate.Replace("##Wave##",$Data.WaveName)
    $subject = $subject.Replace("##Wave##",$Data.WaveName)
    $htmlTemplate = $htmlTemplate.Replace("##ExecutionDate##",$Data.WaveExecutionDate.ToString('dd-MMM-yyyy'))
    $htmlTemplate = $htmlTemplate.Replace("##ExecutionEndDate##",$Data.WaveExecutionEndDate.ToString('dd-MMM-yyyy'))
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