#!pwsh
param (
    # name of the output image
    [bool]$Test =  $true
)

cls


$Wave = "Wave11.46"
$Waves = "Wave11.46,wave11.46w"
# Initialize an empty array
$array = @()
$Wavefolder = $Wave.Replace(" ","_");
$WaveId =0;
$WaveStart = "";
$WaveEnd = "";
$Counter =1;
$Output = "";
$WaveOutputFilPath = "C:\Temp\OCI\$Wavefolder\BatchNotification_email_" + $(Get-Date).ToString("yymmddHHmmssff") +  ".txt" 
$InvalidEmails = @()

#Note: Handle $Test carefully, if set to false emails will go to email-list from database for safe side always keep it true
#$Test= $true;

Write-Host "The current status is: $($Test)"


# Define email details
$from = "prashanth.garlapally.ext@bayer.com"  
$to = @("prashanth.garlapally.ext@bayer.com")

 $CC = @("prashanth-kumar.garlapally@capgemini.com"
        ,"sagar.dudhawade@capgemini.com"
        ,"phani.ramcharan-adiraju@capgemini.com"
        ,"ieda.wolf@capgemini.com"
        ,"kornelius.friesen@capgemini.com"
        ,"panduru.bhaskar@capgemini.com"
        ,"robert.robson@bayer.com"
        ,"kummitha-prasanna-lalitha.devi@capgemini.com"
        ,"muthuraman.renganathan@capgemini.com"       
        ,"madhvi.a.madhvi@capgemini.com"
        ,"priya.l.s@capgemini.com"
        )

 $BCC = @("PCECoreCognizantTeam@bayer.com"
  ,"karthik.manne@bayer.com"
 ,"PCE-CS@bayer.com"
 ,"guilherme.viggiani@bayer.com"
 ,"ketan.waghela@capgemini.com"
 ,"surendra-kumar.kadali@capgemini.com"
   ,"juliana.mendonca@bayer.com"
   ,"heloisa.kronemberger@bayer.com"
   ,"giacomo.vinci@capgemini.com"
   ,"pablo.damico@bayer.com"
   ,"sagar.dudhawade@capgemini.com"
,"devenderreddy.vadde.ext@bayer.com"
,"kornelius.friesen@capgemini.com"
,"PCE-CS@bayer.com"
,"PCECoreCognizantTeam@bayer.com"
,"ashish.thakur@bayer.com"
,"prasanth.bandi@bayer.com"
,"rahul.sharma1.ext@bayer.com"
,"debmallya.sahana.ext@bayer.com"
,"saratbabu.pericherla@cognizant.com"
,"karthik.manne@bayer.com"
,"beverly.baker@bayer.com"
,"jorge.echeverria@bayer.com"
,"pablo.damico@bayer.com"
,"heloisa.kronemberger@bayer.com"
,"beverly.baker@bayer.com"
,"glenn.frasca@bayer.com"
,"saratbabu.pericherla@cognizant.com"
,"Ruthmary.Aaluri@cognizant.com"
,"manohar.karunakaram.ext@bayer.com"
,"satyavikram.nurukurthy.ext@bayer.com"
,"revathy.sekar@cognizant.com"
,"guilherme.viggiani@bayer.com"
,"sudhahari.k@cognizant.com"
,"ricardo.moreno@bayer.com"
,"syed.barkavi.ext@bayer.com"
,"muskan.bhardwaj.ext@bayer.com"
,"erich.sander@bayer.com"
,"harika.nallapati.ext@bayer.com"
,"Guido.Guckelsberger@bayer.com"
,"sushil.jain.ext@bayer.com"
,"magali.cosquer@bayer.com"
,"glenn.frasca@bayer.com"
,"stephan.boehme@bayer.com"
,"joern.bremer@bayer.com"
,"tejas.bhave@capgemini.com"
,"ravi.parakulam@bayer.com"
,"sushil.jain.ext@bayer.com"
,"deborah.rucker@bayer.com"
,"akash.prasad.ext@bayer.com"
,"ravi.parakulam@bayer.com"
,"glenn.frasca@bayer.com"
,"meikel.weber@bayer.com"
,"stephan.boehme@bayer.com"
,"joern.bremer@bayer.com"
,"magali.cosquer@bayer.com"
,"Matthieu.Bouille@bayer.com"
,"Mirco.Rudolf@bayer.com"
,"ranjesh.kumar@capgemini.com"
,"tejas.bhave@capgemini.com"
,"marcel.jakob@bayer.com"
,"Shailesh.Kamble@cognizant.com"
,"lukas.reckebeil@bayer.com"
,"saratbabu.pericherla@cognizant.com"
,"CB.AnuVarshini@cognizant.com"
,"Dilipkumar.Rajan@cognizant.com"
,"S.Bhuvaneswari@cognizant.com"
,"Celestinemaryletitia.J@cognizant.com"
,"Chintakunta.Supraja@cognizant.com"
,"ravi.parakulam@bayer.com"
,"lukas.reckebeil@bayer.com"
,"erich.sander@bayer.com"
,"pravin.katkade@capgemini.com"
,"deborah.rucker@bayer.com"
,"lukas.reckebeil@bayer.com"
,"meikel.weber@bayer.com"
,"akash.subugade.ext@bayer.com"
,"giacomo.vinci@capgemini.com"
,"panduru.bhaskar@capgemini.com"
,"robert.robson@bayer.com"
,"juliana.mendonca@bayer.com"
,"jorge.echeverria@bayer.com"
,"pablo.damico@bayer.com"
,"surendra-kumar.kadali@capgemini.com"
,"ketan.waghela@capgemini.com"
,"guilherme.viggiani@bayer.com"
)

function ValidateEmailAddress {
param (
[string]$EmailAddress
)

    $emailRegex = ‘^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$’
$isValid = $EmailAddress -match $emailRegex

    return $isValid
}

$WaveStart = $null
$WaveEnd = $null
$TableData = ""

$Query = “exec spGetOCIWaves_VM_Status '" + $Waves + "' "

$Query

$Data = Invoke-SQLcmd -ServerInstance BYUS226VXYE -Database "OCIWaveDb" -Query $Query -TrustServerCertificate

$Data

$rowCount = $Data | Measure-Object | Select-Object -ExpandProperty Count
#$rowCount



if ($rowCount -gt 0) {
    Write-Output "Rows returned: $rowCount"


} else {
    Write-Output "No rows returned."
}

if( $rowCount.Count -gt 0) {
 
  ForEach ($Row in $Data) {

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



     try {
      $bgcolor  = ""
        if ( $Row.MigrationStatusId -eq 13 ) { 
				$bgcolor  = "background-color:#ccffcc;"
			}
            elseif ( $Row.MigrationStatusId -eq 14 ) { 
			$bgcolor  = "background-color:#4d7ac4;"
			 
			}
			elseif ( $Row.MigrationStatusId -eq 11 ) { 
			$bgcolor  = "background-color:#edbd07;"
			 
			}
            elseif ( $Row.MigrationStatusId -eq 12 ) { 
			$bgcolor  = "background-color:#f7ffcc;"
			 
			}
            elseif ( $Row.MigrationStatusId -eq 7 ) { 
			$bgcolor  = "background-color:#90D5FF;"
			 
			}


        $TableData += "<tr><td>" + $Row.WaveName + "</td>"
         
        $TableData += "<td>" + $Row.VMName + "</td>"  
              
        if ( $Row.MigrationStatusId -eq 7 ) {
        $TableData += "<td style='vertical-align:top; " + $bgcolor +" '><b>" + $Row.WaveVMStatus + "</b></td>"             
        } else {
        $TableData += "<td style='vertical-align:top; " + $bgcolor +" '>" + $Row.WaveVMStatus + "</td>"             
        
        }
        #$TableData += "<td>" + $Row.OS + "</td>"      
        $TableData += "<td>" + $Row.IPAddress + "</td>"
        $TableData += "<td>" + "<UL><li>" +$Row.Apps.Replace(",", "</li><li>")+ "</li></UL>" + "</td>"         
        $TableData += "</tr>"

     }  catch {
                    Write-Host "Failed to send email to $recipient. Error: $_"
                }

  }

      
      # Define SMTP server details
        $smtpServer = "10.190.58.79"  
        $smtpPort = 25  # Common SMTP port for unauthenticated submission

        # Define email details
        $from = "prashanth.garlapally.ext@bayer.com"  
        #$to = @("naresh.yerragunta.ext@bayer.com","prashanth.garlapally.ext@bayer.com","disha.rochlani@bayer.com") 
        #$to = @("prashanth.garlapally.ext@bayer.com")
        #$CC =  @("prashanth.garlapally.ext@bayer.com","prashanth-kumar.garlapally@capgemini.com","surendra-kumar.kadali@capgemini.com")                 
        #$BCC = @("prashanth.garlapally.ext@bayer.com")
        #uncomment if want to email the stakeholders
        $BCC =  $listA
           
        $subject = "CCP-Azure Native Migration " + $Waves + ": Migration Activity Status."
        $body = "This is a test email to check SMTP functionality from AVS migration project VM."
        $templatePath = "C:\Temp\OCI\Emails\OCI_email_MigSet_status_notify_v1.html"
        $htmlTemplate = Get-Content -Path $templatePath -Raw
        $htmlTemplate = $htmlTemplate.Replace("##Wave##",$Waves)
        $htmlTemplate = $htmlTemplate.Replace("##StatusData##",$TableData)     
         $body = $htmlTemplate

        if ($Test)  {
                    $subject  = "Test Email:=" + $subject 
                     $CC =  @("prashanth.garlapally.ext@bayer.com","prashanth-kumar.garlapally@capgemini.com","phani.adiraju.ext@bayer.com","phani.ramcharan-adiraju@capgemini.com")
                      $body = $htmlTemplate + $CC + $BCC                     
                      $BCC = @("prashanth.garlapally.ext@bayer.com")
                    }
         try {
                Send-MailMessage -From $from -To $to -CC $CC -BCC $BCC -Subject $subject -Body $body -SmtpServer $smtpServer -Port $smtpPort -BodyAsHtml -Priority High
                 
                    $Output= "Migration status email sent successfully to $to @ $(Get-Date)"
                     Write-Host $Output
                       $Output | Out-File -FilePath $WaveOutputFilPath -Append 
                                $CC | Out-File -FilePath $WaveOutputFilPath -Append 
                                $BCC | Out-File -FilePath $WaveOutputFilPath -Append 
                
               # Start-Sleep -s $SleepSeconds
                } catch {
                    Write-Host "Failed to send email to $recipient. Error: $_"
                }


}
