cls
#Note : update Variables before running the script

$Wave = "Wave13"
#Note: Handle $Test carefully if set to false emails will go to email-list from database else set to $true
$Test= $true;
$SingleRecord =$true


#start of Function

function ValidateEmailAddress {
param (
[string]$EmailAddress
)

    $emailRegex = ‘^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$’
$isValid = $EmailAddress -match $emailRegex

    return $isValid
}


#End of Function


$Wavefolder = $Wave.Replace(" ","_");
$Counter =1;
$SleepSeconds = 2;
$Output = "";
$WaveOutputFilPath = "C:\Temp\$Wavefolder\VMMigrated_email_" + $(Get-Date).ToString("yymmddHHmmssff") +  ".txt" 

$firstrow = $true;
$WaveVMID = 0;

$Query = “select distinct top 1  v.loc, V.appgroup, V.WaveVMID, W.WaveName, Upper(v.VMName) as Server, dbo.fnWaveVMEmailData(v.WaveVMID ) as 'Email', dbo.fnWaveVMBOSO_EmailData(v.WaveVMID ) as 'BOSOEmails', V.IPAddress,V.OS, isnull(V.Sys_Owner,'N/A') as Sys_Owner , isnull(V.BEATID,'N/A') as BEATID ,
ISNULL(V.Apps,'N/A') as Apps,W.WaveExecutionDate , w.WaveExecutionEndDate from tblWaveVM V  inner join tblWave W on W.WaveID =  V.WaveID
where W.WaveName =  ltrim(rtrim('" + $Wave + "'))  "
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

if ( $firstrow ) {
   
        if ($SingleRecord) {
        $firstrow = $false
          
        }

       

        $WaveVMID = 0;
        $WaveVMID  = $Row.WaveVMID;
        $list = ""
        $ListBOSOEmails = ""
        if  ($Row.Email -isnot [DBNull]) {
         $list = $Row.Email.Trim(); 
        }                      
       
        $listA = $list.Split(",")
        $listA = $listA | Select-Object -Unique

        #Now get BOSOEmails

         if  ($Row.BOSOEmails -isnot [DBNull]) {
         $list = $Row.BOSOEmails.Trim(); 
        }                      
       
        $listB = $list.Split(",")
        $listB = $listB | Select-Object -Unique

        
    

        # Define SMTP server details
        $smtpServer = "10.190.58.79"  
        $smtpPort = 25  # Common SMTP port for unauthenticated submission

        # Define email details
        $from = "prashanth.garlapally.ext@bayer.com"  
        #$to = @("naresh.yerragunta.ext@bayer.com","prashanth.garlapally.ext@bayer.com","disha.rochlani@bayer.com") 
        $to = @("prashanth.garlapally.ext@bayer.com")

         $CC =  @("prashanth.garlapally.ext@bayer.com","prashanth-kumar.garlapally@capgemini.com")
         
         

        $listA.ForEach( 
        {
            
            if (!$CC.Contains( ($_).Trim())) {
                   if (($_).Trim()  -ne '') {

                    if  (ValidateEmailAddress(($_).Trim())) {
                          $CC += $_                                                
                        }else {
                            $InvalidEmails +=$_
                                Write-Output "Invalid Email." + $_
                        }

                    
                   }
                   
               }
        })
        $CC = $CC | Select-Object -Unique
        $listA = $CC

        #now addtach to CC
          $listB.ForEach( 
        {
            
            if (!$to.Contains( ($_).Trim())) {
                   if (($_).Trim()  -ne '') {
                    if  (ValidateEmailAddress(($_).Trim())) {
                          #$to += $_                                               
                        }else {
                            $InvalidEmails +=$_
                                Write-Output "Invalid Email." + $_
                        }
                   
                   }
                   
               }
        })
        $to = $to | Select-Object -Unique
        $listB = $to



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
    ,"PCECoreCognizantTeam@bayer.com"
    ,"PCE-CS@bayer.com"
    ,"juliana.mendonca@bayer.com"
    ,"analia.monzon@bayer.com"
    )

        if ($Test)  {
            $CC = @("demudu.bojja@capgemini.com","surendra-kumar.kadali@capgemini.com")
            $BCC  = @("prashanth.garlapally.ext@bayer.com","prashanth-kumar.garlapally@capgemini.com")
            $to = @("prashanth.garlapally.ext@bayer.com")
        }
        

       
 
        $subject = "AVS Migration ##Wave##: ##Server## (Apps: ##Apps##) Pre-Notification. "
        $body = "This is a test email to check SMTP functionality from AVS migration project VM."
        $templatePath = "C:\Temp\Email\email_WaveVM_PreWeek_notify_v1.html"
        $htmlTemplate = Get-Content -Path $templatePath -Raw
        $htmlTemplate = $htmlTemplate.Replace("##Wave##",$Row.WaveName)
         $strApps  = ""
        $strApps  = $Row.Apps
        $strApps = $strApps.Replace("*** Without linked BEAT application in cmdb_inventory ***", "No app linked to server")
        $strApps = $strApps.Replace("*** Not in PCE report, so no app linked from CMDB ***", "No app linked to server")
        

        $subject = $subject.Replace("##Wave##",$Row.WaveName).Replace("##Server##",$Row.Server).Replace("##Apps##",$strApps)
        $htmlTemplate = $htmlTemplate.Replace("##ExecutionDate##",$Row.WaveExecutionDate.ToString('dd-MMM-yyyy'))
        $htmlTemplate = $htmlTemplate.Replace("##ExecutionEndDate##",$Row.WaveExecutionEndDate.ToString('dd-MMM-yyyy'))
        
        $htmlTemplate = $htmlTemplate.Replace("##Server##",$Row.Server)
        $htmlTemplate = $htmlTemplate.Replace("##MigStart##",$Row.MigStart)
        $htmlTemplate = $htmlTemplate.Replace("##MigEnd##",$Row.MigEndTime)
        
        $htmlTemplate = $htmlTemplate.Replace("##Percentage##",$Row.Percentage)
        $htmlTemplate = $htmlTemplate.Replace("##Status##",$Row.MigState)

        $htmlTemplate = $htmlTemplate.Replace("##OS##",$Row.OS)
        $htmlTemplate = $htmlTemplate.Replace("##SysOwner##",$Row.Sys_Owner)
        $htmlTemplate = $htmlTemplate.Replace("##Apps##",$Row.Apps)
        $htmlTemplate = $htmlTemplate.Replace("##BeatID##",$Row.BEATID)
        $htmlTemplate = $htmlTemplate.Replace("##IPAddress##",$Row.IPAddress)


        if ($Test)  {
        $subject  = "Test Email:=" + $subject 
        $body = $htmlTemplate + $listA + "<br/>To Address:" +  $listB
        
        } else {
        $body = $htmlTemplate 
        }
        

        # Send test emails
        foreach ($recipient in $to) {
            try {
                Send-MailMessage -From $from -To $to -CC $CC -BCC $BCC -Subject $subject -Body $body -SmtpServer $smtpServer -Port $smtpPort -BodyAsHtml -Priority High 
                $Output= "Email-$Counter server $($Row.Server.Trim()) Migration email sent successfully to $to @ $(Get-Date)"
                Write-Output $Output
                $Output | Out-File -FilePath $WaveOutputFilPath -Append 
                $listA | Out-File -FilePath $WaveOutputFilPath -Append 
                 if (!$Test)  {
                        $Query =  "Update tblWaveVM set [MigrationStatusId] = 7 ,[MigrationCompleteDate] = getDate(),[EmailDate] = getDate() where WaveVMID = $WaveVMID ;"
                        Invoke-SQLcmd -ServerInstance BYUS226VXYE -Database "WavesDb" -Query $Query -TrustServerCertificate
                        
                    }


                
                Start-Sleep -s $SleepSeconds
                } catch {
                    Write-Host "Failed to send email to $recipient. Error: $_"
                }
        } #foreach end
      }
      $Counter +=1;
    }
}