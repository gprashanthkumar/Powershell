cls
#Note : update Variables before running the script

$Wave = "Wave9"
$Wavefolder = $Wave.Replace(" ","_");
$firstrow = $true;
$Counter =1;
$SleepSeconds = 2;
$Output = "";
$WaveOutputFilPath = "C:\Temp\$Wavefolder\VMMigrated_email_" + $(Get-Date).ToString("yymmddHHmmssff") +  ".txt" 
#Note: Handle $Test carefully if set to false emails will go to email-list from database else set to $true
$Test= $true;
$WaveVMID = 0;

$Query = “select distinct v.loc, V.appgroup, V.WaveVMID, W.WaveName, Upper(M.Server) as Server, M.Percentage , MigState, MigStart, MigEndTime, dbo.fnWaveVMEmailData(v.WaveVMID ) as 'Email'
, V.IPAddress,V.OS, isnull(V.Sys_Owner,'N/A') as Sys_Owner , isnull(V.BEATID,'N/A') as BEATID , ISNULL(V.Apps,'N/A') as Apps
,W.WaveExecutionDate , WaveExecutionEndDate from [dbo].[tblHCXMigation_status_data] M
inner join  tblWaveVM V  on upper(ltrim(rtrim(v.VMName))) = upper(ltrim(rtrim(M.server)))
inner join tblWave W on W.WaveID =  V.WaveID
where M.Batchid = (select Max(BatchID) from  [dbo].[tblHCXMigation_status_data])
and rtrim(ltrim(M.[Percentage])) ='100' and ltrim(rtrim(m.MigState)) = 'MIGRATED' and w.WaveName = ltrim(rtrim('" + $Wave + "'))  and isnull(MigrationCompleteDate,'')= '' "
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
        #$firstrow = $false

        $WaveVMID = 0;
        $WaveVMID  = $Row.WaveVMID;               
        $list = $Row.Email.Trim();
        $listA = $list.Split(",")
        $listA = $listA | Select-Object -Unique
    

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
                    $CC += $_
                   }
                   
               }
        })
        $CC = $CC | Select-Object -Unique
        $listA = $CC
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
        }
        

       
 
        $subject = "AVS Migration ##Wave##: ##Server## (Apps: ##Apps##) Migrated. "
        $body = "This is a test email to check SMTP functionality from AVS migration project VM."
        $templatePath = "C:\Temp\email\email_systemMigrated_notifyv2.html"
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
        $body = $htmlTemplate + $listA
        
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
        }
      }
      $Counter +=1;
    }
}