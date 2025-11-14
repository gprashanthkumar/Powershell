cls
Write-Output "Executing time.......$(Get-Date) `n`n"
#Note : update Variables before running the script

$Wave = "Wave11.46"
$Waves = "Wave11.46,wave11.46w"
# Initialize an empty array

#Note: Handle $Test carefully if set to false emails will go to email-list from database else set to $true
$Test= $false;
$SingleRecord =$true



$Group = -1
$Wavefolder = $Wave.Replace(" ","_");
$Counter =1;
$SleepSeconds = 2;
$Output = "";
$WaveOutputFilPath = "C:\Temp\OCI\$Wavefolder\VMMigrated_email_" + $(Get-Date).ToString("yymmddHHmmssff") +  ".txt" 

#Dont 
$firstrow = $true;
$WaveVMID = 0;



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




$Query = “select distinct V.loc, V.appgroup
, V.WaveVMID, W.WaveName
, Upper(V.VMNAME) as [Server]

, dbo.fnWaveVMEmailData(v.WaveVMID ) as 'Email'
 , dbo.fnWaveVMBOSO_EmailData(v.WaveVMID ) as 'BOSOEmails'
, V.IPAddress,V.OS, isnull(V.Sys_Owner,'N/A') as Sys_Owner 
, isnull(V.BEATID,'N/A') as BEATID 
, ISNULL(V.Apps,'N/A') as Apps
,W.WaveExecutionDate , WaveExecutionEndDate 
,isnull(v.NEW_IPAddress ,'') as NEWIPAddress
from tblwavevm v inner join tblwave w on w.WaveID = v.WaveID
where w.WaveName in (SELECT value FROM STRING_SPLIT('" + $Waves + "', ','))
and (isnull(v.EmailDate,'')= '') and MigrationStatusId = 7"


if ($Group -eq 0) {
$Query += "and ISNULL(V.Apps,'N/A') not like '%Citrix%'"

}elseif ($Group -eq 1) {
$Query += "and ISNULL(V.Apps,'N/A')  not like '%Citrix%'"
$Query += "and Upper(V.VMNAME)  in   ( 'IRVUWLAPRD00','IRVUWLPRD01','IRVUWLPRD02','IRVUWLPRD03','STLUJMSIPRD00','STLUJMSIPRD01','STLUJMSIPRD02','STLUJMSIPRD03'
 )  "

}elseif ($Group -eq 2) {
$Query += "and ISNULL(V.Apps,'N/A')  not like '%Citrix%'"
$Query += "and Upper(V.VMNAME) not in ('BY-SDRAMIG2') "


}elseif ($Group -eq 3) {
$Query += "and ISNULL(V.Apps,'N/A')  like '%Citrix%'"

}
elseif ($Group -eq 4) {

$Query += "and ISNULL(V.Apps,'N/A')  like '%Citrix%'"
$Query += "and Upper(V.VMNAME)  in ('BY0X7W', 'BY0X7X', 'BYDE276Z11S','BYDE1449CYU' ) "
}
elseif ($Group -eq 5) {

$Query += "and ISNULL(V.Apps,'N/A')  like '%Citrix%'"
$Query += "and Upper(V.VMNAME) not in ('BYUS0080YD2' ,'BYUS0086PZ9') "
}






$Query
$Data = Invoke-SQLcmd -ServerInstance BYUS226VXYE -Database "OCIWaveDB" -Query $Query -TrustServerCertificate

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
                          $to += $_                                               
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
    ,"guilherme.viggiani@bayer.com"
    ,"sandor.szaszi@bayer.com"
    ,"PCECoreCognizantTeam@bayer.com"
    ,"PCE-CS@bayer.com"
    ,"juliana.mendonca@bayer.com"
    ,"analia.monzon@bayer.com"
    ,"roberto.luwita@bayer.com"
    )

        if ($Test)  {
            $CC = @("demudu.bojja@capgemini.com","surendra-kumar.kadali@capgemini.com")
            $BCC  = @("prashanth.garlapally.ext@bayer.com","prashanth-kumar.garlapally@capgemini.com")
            $to = @("prashanth.garlapally.ext@bayer.com")
        }
        

       
 
        $subject = "CCP-Azure native Migration ##Wave##: ##Server## (Apps: ##Apps##) Migrated. "
        $body = "This is a test email to check SMTP functionality from AVS migration project VM."
        $templatePath = "C:\Temp\OCI\emails\OCI_email_SystemMigrated_notify_v1.html"
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
        
        $htmlTemplate = $htmlTemplate.Replace("##Percentage##","100%")
        $htmlTemplate = $htmlTemplate.Replace("##Status##","MIGRATED")

        $htmlTemplate = $htmlTemplate.Replace("##OS##",$Row.OS)
        $htmlTemplate = $htmlTemplate.Replace("##SysOwner##",$Row.Sys_Owner)
        $htmlTemplate = $htmlTemplate.Replace("##Apps##",$Row.Apps)
        $htmlTemplate = $htmlTemplate.Replace("##BeatID##",$Row.BEATID)
        $htmlTemplate = $htmlTemplate.Replace("##IPAddress##",$Row.IPAddress)
		$htmlTemplate = $htmlTemplate.Replace("##NEWIPAddress##",$Row.NEWIPAddress)


        if ($Test)  {
        $subject  = "Test Email:=" + $subject 
        $body = $htmlTemplate + $listA + "<br/>To Address:" +  $listB
        
        } else {
        $body = $htmlTemplate 
        }
        

        # Send test emails
        #foreach ($recipient in $to) {
            try {
                #
                Send-MailMessage -From $from -To $to -CC $CC -BCC $BCC -Subject $subject -Body $body -SmtpServer $smtpServer -Port $smtpPort -BodyAsHtml -Priority High 
                $Output= "Email-$Counter server $($Row.Server.Trim()) Migration email sent successfully to $to @ $(Get-Date)"
                Write-Output $Output
                $Output | Out-File -FilePath $WaveOutputFilPath -Append 
                $listA | Out-File -FilePath $WaveOutputFilPath -Append 
                 if (!$Test)  {
                        $Query =  "Update tblWaveVM set [MigrationStatusId] = 7 ,[MigrationCompleteDate] = getDate(),[EmailDate] = getDate() where WaveVMID = $WaveVMID ;"
                        Invoke-SQLcmd -ServerInstance BYUS226VXYE -Database "OCIWaveDB" -Query $Query -TrustServerCertificate
                        
                    }


                
                Start-Sleep -s $SleepSeconds
                } catch {
                    Write-Host "Failed to send email to $recipient. Error: $_"
                }
        #}
      }
      $Counter +=1;
    }
}