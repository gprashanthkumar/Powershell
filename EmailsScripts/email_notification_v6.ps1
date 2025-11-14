cls
#Note : update Variables before running the script

$Wave = "Wave30"
$Wavefolder = $Wave.Replace(" ","_");
$WaveId =0;
$WaveStart = "";
$WaveEnd = "";
$Counter =1;
$Output = "";
$WaveOutputFilPath = "C:\Temp\$Wavefolder\BatchNotification_email_" + $(Get-Date).ToString("yymmddHHmmssff") +  ".txt" 
$InvalidEmails = @()

#Note: Handle $Test carefully, if set to false emails will go to email-list from database for safe side always keep it true
$Test= $false;



# Define SMTP server details
$smtpServer = "10.190.58.79"  
 $smtpPort = 25  # Common SMTP port for unauthenticated submission

# Define email details
$from = "prashanth.garlapally.ext@bayer.com"  
$to = @("prashanth.garlapally.ext@bayer.com")

 $CC = @("prashanth-kumar.garlapally@capgemini.com")
  $BCC = @("christian.billig@bayer.com"
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
                ,"bmalter@microsoft.com"
                ,"Ramon.diegel@microsoft.com"
                ,"hrdeepthi@microsoft.com"
                ,"bayeravscloudprojectteam.de@capgemini.com"
                ,"guilherme.viggiani@bayer.com"
                ,"sandor.szaszi@bayer.com" 
                ,"prashanth.garlapally.ext@bayer.com"
                ,"prashanth-kumar.garlapally@capgemini.com"
                ,"PCECoreCognizantTeam@bayer.com"
                ,"PCE-CS@bayer.com"
                ,"analia.monzon@bayer.com"
                ,"roberto.luwita@bayer.com"
                               
                )

function ValidateEmailAddress {
param (
[string]$EmailAddress
)

    $emailRegex = ‘^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$’
$isValid = $EmailAddress -match $emailRegex

    return $isValid
}


$Query = “select distinct W.WaveID,v.WaveVMID, W.WaveName,  isnull( dbo.fnWaveVMEmailData(v.WaveVMID ),'') as 'Email', W.WaveExecutionDate , WaveExecutionEndDate from 
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
                     $listA = $listA | Select-Object -Unique

                    

                    

                            $listA.ForEach( 
                            {
                        
                                if (!$BCC.Contains( ($_).Trim())) {
                                       if (($_).Trim()  -ne '') {
                                            if  (ValidateEmailAddress(($_).Trim())) { 
                                                $BCC += $_                                                
                                            }else {
                                                $InvalidEmails +=$_
                                                 Write-Output "Invalid Email." + $_
                                            }
                                       
                                       }
                   
                                   }
                            })

                    $listA = $BCC | Select-Object -Unique
                    
                   
        

                   

                    # Send test emails
                    foreach ($recipient in $to) {
                       
                    }
                  $WaveStart = $Row.WaveExecutionDate.ToString('dd-MMM-yyyy')
                  $WaveEnd = $Row.WaveExecutionEndDate.ToString('dd-MMM-yyyy')
                }

                 try {
                    
                 

                     $BCC = $BCC | Select-Object -Unique
                    $subject = "AVS Migration Project: Migration ##Wave## - Notification"
                    $body = "This is a test email to check SMTP functionality from AVS migration project VM."
                    $templatePath = "C:\Temp\email\email_notifyv5.html"
                    $htmlTemplate = Get-Content -Path $templatePath -Raw
                    $htmlTemplate = $htmlTemplate.Replace("##Wave##",$Wave)
                    $subject = $subject.Replace("##Wave##",$Wave)
                    $htmlTemplate = $htmlTemplate.Replace("##ExecutionDate##",$WaveStart)
                    $htmlTemplate = $htmlTemplate.Replace("##ExecutionEndDate##",$WaveEnd)

                    
                    if ($Test)  {
                    $subject  = "Test Email:=" + $subject 
                    $body = $htmlTemplate + $CC + $BCC
                    } else {
                    $body = $htmlTemplate 
                    }
                     if ($Test)  {
                        "CC list `n -------`n" | Out-File -FilePath $WaveOutputFilPath -Append 
                        $CC | Out-File -FilePath $WaveOutputFilPath -Append 
                        $CC = @("prashanth-kumar.garlapally@capgemini.com","demudu.bojja@capgemini.com","surendra-kumar.kadali@capgemini.com", "phani.adiraju.ext@bayer.com")
                        "BCC list `n -------`n" | Out-File -FilePath $WaveOutputFilPath -Append 
                        $BCC | Out-File -FilePath $WaveOutputFilPath -Append 
                        $BCC = @("prashanth.garlapally.ext@bayer.com","prashanth-kumar.garlapally@capgemini.com")

                    }
                          
                            
                            Send-MailMessage -From $from -To $to -CC $CC -BCC $BCC -Subject $subject -Body $body -SmtpServer $smtpServer -Port $smtpPort -BodyAsHtml -Priority High
                            $Output= "Email-$Counter $Wave Migration notification sent successfully to $to @ $(Get-Date)"
                            Write-Output $Output
                            $Output | Out-File -FilePath $WaveOutputFilPath -Append 
                            $CC | Out-File -FilePath $WaveOutputFilPath -Append 
                            $BCC | Out-File -FilePath $WaveOutputFilPath -Append 

                            if (!$Test)  {
                                $Query =  "Update tblWaveVM set [MigrationStatusId] = case  VMOnline when 0 then 2 when 1 then 2 when  -1 then 5 else MigrationStatusId end where  WaveID = $WaveId ;"
                                Invoke-SQLcmd -ServerInstance BYUS226VXYE -Database "WavesDb" -Query $Query -TrustServerCertificate
                                }
                       
                
                            
                            } catch {
                                Write-Host "Failed to send email to $recipient. Error: $_"
                            }

$InvalidEmails
}