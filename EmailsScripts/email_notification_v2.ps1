cls
#Note : update Variables before running the script

$Wave = "Wave-1b and Wave-2"
$Wavefolder = $Wave.Replace(" ","_");
$WaveId =0;
$WaveStart = "";
$WaveEnd = "";
$firstrow = $true;
$Counter =1;
$Output = "";
$WaveOutputFilPath = "C:\Temp\$Wavefolder\BatchNotification_email_" + $(Get-Date).ToString("yymmddHHmmssff") +  ".txt" 
#Note: Handle $Test carefully, if set to false emails will go to email-list from database for safe side always keep it true
$Test= $true;

# Define SMTP server details
$smtpServer = "10.190.58.79"  
 $smtpPort = 25  # Common SMTP port for unauthenticated submission

# Define email details
$from = "prashanth.garlapally.ext@bayer.com"  
$to = @("prashanth.garlapally.ext@bayer.com")

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
                ,"sandor.szaszi@bayer.com"                
                )


$Query = “select distinct W.WaveID, W.WaveName,  dbo.fnWaveVMEmailData(v.WaveVMID ) as 'Email', W.WaveExecutionDate , WaveExecutionEndDate from 
tblWaveVM V inner join tblWave W on W.WaveID =  V.WaveID where V.VMOnline in (0,1) and  w.WaveName = ltrim(rtrim('" + $Wave + "')) "

$Query

$Data = Invoke-SQLcmd -ServerInstance BYUS226VXYE -Database "WavesDb" -Query $Query -TrustServerCertificate

$Data

$rowCount = $Data | Measure-Object | Select-Object -ExpandProperty Count



if ($rowCount -gt 0) {
    Write-Output "Rows returned: $rowCount"


} else {
    Write-Output "No rows returned."
}

if( $rowCount.Count -gt 0) {
 $Row.WaveName +"`n"  | Out-File -FilePath $WaveOutputFilPath -Append 


            ForEach ($Row in $Data) {
            
                    $WaveId = $Row.WaveID;
                    $list = $Row.Email.Trim();
                    $listA = $list.Split(",")
    

                    

                    

                    $listA.ForEach( 
                    {
                        
                        if (!$CC.Contains( ($_).Trim())) {
                               if (($_).Trim()  -ne '') {
                                $CC += $_
                               }
                   
                           }
                    })
                    $listA = $CC
                   
        

                   

                    # Send test emails
                    foreach ($recipient in $to) {
                       
                    }
                  $WaveStart = $Row.WaveExecutionDate.ToString('dd-MMM-yyyy')
                  $WaveEnd = $Row.WaveExecutionEndDate.ToString('dd-MMM-yyyy')
                }

                 try {
                    $BCC = @("prashanth.garlapally.ext@bayer.com","prashanth-kumar.garlapally@capgemini.com")
 
                    $subject = "AVS Migration Project: Migration ##Wave## - Notification"
                    $body = "This is a test email to check SMTP functionality from AVS migration project VM."
                    $templatePath = "C:\Temp\email\email_notifyv4.html"
                    $htmlTemplate = Get-Content -Path $templatePath -Raw
                    $htmlTemplate = $htmlTemplate.Replace("##Wave##",$Wave)
                    $subject = $subject.Replace("##Wave##",$Wave)
                    $htmlTemplate = $htmlTemplate.Replace("##ExecutionDate##",$WaveStart)
                    $htmlTemplate = $htmlTemplate.Replace("##ExecutionEndDate##",$WaveEnd)

                    
                    if ($Test)  {
                    $subject  = "Test Email:=" + $subject 
                    $body = $htmlTemplate + $CC
                    } else {
                    $body = $htmlTemplate 
                    }
                     if ($Test)  {
                        $CC | Out-File -FilePath $WaveOutputFilPath -Append 
                        $CC = @("prashanth-kumar.garlapally@capgemini.com")
                    }
                          
                            Send-MailMessage -From $from -To $recipient -CC $CC -BCC $BCC -Subject $subject -Body $body -SmtpServer $smtpServer -Port $smtpPort -BodyAsHtml -Priority High
                            $Output= "Email-$Counter $Wave Migration notification sent successfully to $recipient @ $(Get-Date)"
                            Write-Output $Output
                            $Output | Out-File -FilePath $WaveOutputFilPath -Append 
                            $CC | Out-File -FilePath $WaveOutputFilPath -Append 

                            if (!$Test)  {
                                $Query =  "Update tblWaveVM set [MigrationStatusId] = case  VMOnline when 0 then 2 when 1 then 2 when  -1 then 5 else MigrationStatusId end where  WaveID = $WaveId ;"
                                Invoke-SQLcmd -ServerInstance BYUS226VXYE -Database "WavesDb" -Query $Query -TrustServerCertificate
                                }
                       
                
                            
                            } catch {
                                Write-Host "Failed to send email to $recipient. Error: $_"
                            }
}