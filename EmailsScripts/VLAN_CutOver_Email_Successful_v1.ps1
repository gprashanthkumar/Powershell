cls
#Note : update Variables before running the script

$Wave = "VC-1089 and 1910"

#Note: Handle $Test carefully if set to false emails will go to email-list from database else set to $true
$Test= $true;
$SingleRecord =$true;


$WaveVMID = 0;
$Counter =1;
$SleepSeconds = 2;
$firstrow = $true;
$Output = "";
$Wavefolder = $Wave.Replace(" ","_");
$WaveOutputFilPath = "C:\Temp\VLANCutOver\$Wavefolder\VMMigrated_email_" + $(Get-Date).ToString("yymmddHHmmssff") +  ".txt" 

$Query = “select c.*, v.WaveVMID,v.VMName as 'Server' , dbo.fnWaveVMEmailData(v.WaveVMID ) as 'Email'
, V.IPAddress,V.OS, isnull(V.Sys_Owner,'N/A') as Sys_Owner ,  ISNULL(V.Apps,'N/A') as Apps
from tblWaveVM v inner join [dbo].[tblVLANCutOver_VMs] cv on cv.VMID  = v.WaveVMID
inner  join [dbo].[tblVLANCutOver] c on  cv.VLANCutOverID  = c.VLANCutOverID
where c.CutOverName = '$Wave'  "
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
 $Row.Server +"`n"  | Out-File -FilePath $WaveOutputFilPath -Append 


ForEach ($Row in $Data) {

if ( $firstrow ) {
        
        
        if ($SingleRecord) {
        $firstrow = $false
          
        }

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

        $CC =  @("prashanth.garlapally.ext@bayer.com","prashanth-kumar.garlapally@capgemini.com","marcel.hennes@bayer.com","michael.jung@bayer.com")
         
         

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
            "CC list `n -------`n" | Out-File -FilePath $WaveOutputFilPath -Append 
            $CC | Out-File -FilePath $WaveOutputFilPath -Append 
            $CC = @("demudu.bojja@capgemini.com","surendra-kumar.kadali@capgemini.com")
            $CC = @("demudu.bojja@capgemini.com","phani.ramcharan-adiraju@capgemini.com")
            "BCC list `n -------`n" | Out-File -FilePath $WaveOutputFilPath -Append 
            $BCC | Out-File -FilePath $WaveOutputFilPath -Append 
            $BCC  = @("prashanth.garlapally.ext@bayer.com","prashanth-kumar.garlapally@capgemini.com")
        }
        

       
 
        $subject = "Planned VLAN Cutover Activity Impacting Server(##Server##) -Application (##Apps##):Successfully Completed"
        $body = "This is a test email to check SMTP functionality from AVS migration project VM."
        $templatePath = "C:\Temp\email\email_cutover_Successfull_v1.html"
        $htmlTemplate = Get-Content -Path $templatePath -Raw
        $htmlTemplate = $htmlTemplate.Replace("##Wave##",$Row.WaveName)
         $strApps  = ""
        $strApps  = $Row.Apps
        $strApps = $strApps.Replace("*** Without linked BEAT application in cmdb_inventory ***", "No app linked to server")
        $strApps = $strApps.Replace("*** Not in PCE report, so no app linked from CMDB ***", "No app linked to server")
        

        $subject = $subject.Replace("##Server##",$Row.Server).Replace("##Apps##",$strApps)
       

        $htmlTemplate = $htmlTemplate.Replace("##Server##",$Row.Server)
        $htmlTemplate = $htmlTemplate.Replace("##CutOverStart##",$Row.CutOverStart)
        $htmlTemplate = $htmlTemplate.Replace("##CutOverEnd##",$Row.CutOverEnd)
        $htmlTemplate = $htmlTemplate.Replace("##CutoverName##",$Row.CutoverName)
        $htmlTemplate = $htmlTemplate.Replace("##VLANNAME##",$Row.VLANNAME)
        
        
        
        
        $htmlTemplate = $htmlTemplate.Replace("##OS##",$Row.OS)
        $htmlTemplate = $htmlTemplate.Replace("##SysOwner##",$Row.Sys_Owner)
        $htmlTemplate = $htmlTemplate.Replace("##Apps##",$Row.Apps)
        $htmlTemplate = $htmlTemplate.Replace("##IPAddress##",$Row.IPAddress)


        if ($Test)  {
        $subject  = "Test Email:=" + $subject 
        $body = $htmlTemplate + $CC + $BCC
        
        
        } else {
        $body = $htmlTemplate 
        }
        

        # Send test emails
        foreach ($recipient in $to) {
            try {
           
                Send-MailMessage -From $from -To $to -CC $CC -BCC $BCC -Subject $subject -Body $body -SmtpServer $smtpServer -Port $smtpPort -BodyAsHtml -Priority High 
                $Output= "Email-$Counter server $($Row.Server.Trim()) VLAN cutover completed email sent successfully to $to @ $(Get-Date)"
                Write-Output $Output
                $Output | Out-File -FilePath $WaveOutputFilPath -Append 
                $listA | Out-File -FilePath $WaveOutputFilPath -Append 
                 if (!$Test)  {
                         $Query =  "Update tblVLANCutOver_VMs set [success] = getDate() where VMID = $WaveVMID ;"
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