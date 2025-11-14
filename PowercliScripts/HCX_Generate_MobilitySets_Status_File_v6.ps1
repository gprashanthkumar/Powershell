cls


# Initialize an empty array
$Wave = "Wave30"
$array = @()
$servers = @()
$vmsarray = @()
$removeArray =@()
$Location  = "US"

<#

$removeArray =@("WAVE27W_USENT_MIG_RAV_1008_03","WAVE27W_USENT_MIG_RAV_1004/07_6","WAVE27W_USENT_MIG_RAV_1012_02","Webl_WAVE27w_USDMZ_MIG_RAV__SEQ06" )
$removeArray +=@("Webl_WAVE27w_USDMZ_MIG_RAV__NOREBOOT","Webl_WAVE27w_USDMZ_MIG_RAV__SEQ11" ,"WAVE27W_USDMZ_MIG_RAV_3001_01", "Webl_WAVE27w_USDMZ_MIG_RAV__SEQ05")
$removeArray += @("Webl_WAVE27w_USCTL_MIG_RAV__SEQ04","Webl_WAVE27w_USCTL_MIG_RAV__SEQ03","Webl_WAVE27w_USCTL_MIG_RAV__NOSEQ","Webl_WAVE27w_USCTL_MIG_RAV__SEQ08")
$removeArray += @("Webl_WAVE27w_USCTL_MIG_RAV__SEQ01","Webl_WAVE27w_USCTL_MIG_RAV__SEQ02","Webl_WAVE27w_USCTL_MIG_RAV__SEQ07")
$removeArray += @("Webl_WAVE27w_USCTL_MIG_RAV__SEQ09","Webl_WAVE27w_USENT_MIG_RAV__SEQ12")
$removeArray += @("Webl_WAVE27w_USCTL_MIG_RAV__SEQ13")


$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE27W_USENT_MIG_RAV_1008_03/1130_06" ; Completed = "1"; Total = "1"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "Webl_WAVE27w_USCTL_MIG_RAV__SEQ13" ; Completed = "4"; Total = "4"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = " WAVE27W_USENT_MIG_RAV_1004/07_6" ; Completed = "2"; Total = "2"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE27W_USENT_MIG_RAV_1012_02" ; Completed = "3"; Total = "3"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "Webl_WAVE27w_USDMZ_MIG_RAV__SEQ06" ; Completed = "2"; Total = "2"; MigState = 'Migrated'; MigrationPeriod = ""}
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "Webl_WAVE27w_USDMZ_MIG_RAV__NOREBOOT" ; Completed = "3"; Total = "3"; MigState = 'Migrated'; MigrationPeriod = ""} 

$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "Webl_WAVE27w_USDMZ_MIG_RAV__SEQ11" ; Completed = "4"; Total = "4"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE27W_USDMZ_MIG_RAV_3001_01" ; Completed = "1"; Total = "1"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "Webl_WAVE27w_USDMZ_MIG_RAV__SEQ05" ; Completed = "4"; Total = "4"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "Webl_WAVE27w_USCTL_MIG_RAV__SEQ04" ; Completed = "2"; Total = "2"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "Webl_WAVE27w_USCTL_MIG_RAV__SEQ03" ; Completed = "3"; Total = "3"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "Webl_WAVE27w_USCTL_MIG_RAV__NOSEQ" ; Completed = "2"; Total = "2"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "Webl_WAVE27w_USCTL_MIG_RAV__SEQ08" ; Completed = "2"; Total = "2"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "Webl_WAVE27w_USCTL_MIG_RAV__SEQ01" ; Completed = "3"; Total = "3"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "Webl_WAVE27w_USCTL_MIG_RAV__SEQ02" ; Completed = "4"; Total = "4"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "Webl_WAVE27w_USCTL_MIG_RAV__SEQ07" ; Completed = "6"; Total = "6"; MigState = 'Migrated'; MigrationPeriod = ""} 


$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "Webl_WAVE27w_USCTL_MIG_RAV__SEQ09" ; Completed = "2"; Total = "2"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "Webl_WAVE27w_USCTL_MIG_RAV__SEQ13" ; Completed = "1"; Total = "1"; MigState = 'Migrated'; MigrationPeriod = ""} 








$removeArray += @("WAVE25_USENT_MIG_RAV_1005/01/02/06/11/06/08_05","WAVE25_USCNTL_MIG_RAV_2700/03_01")






$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "Webl_WAVE27w_USDMZ_MIG_RAV__NOREBOOT" ; Completed = "3"; Total = "3"; MigState = 'Migrated'; MigrationPeriod = ""} 









$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE23_USDMZ_MIG_RAV_3001" ; Completed = "4"; Total = "4"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE23_USENT_MIG_RAV_1007_1130" ; Completed = "8"; Total = "8"; MigState = 'Migrated'; MigrationPeriod = ""} 



$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE22_USENT_MIG_RAV_1001/05/06_03" ; Completed = "3"; Total = "3"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE22_USCNTL_MIG_RAV_2701/4061/62/63_01" ; Completed = "11"; Total = "11"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE22_USENT_MIG_RAV_1909/1019_02" ; Completed = "17"; Total = "17"; MigState = 'Migrated'; MigrationPeriod = ""} 



$removeArray +=@("WAVE21_USENT_MIG_RAV_1011_03","WAVE21_USENT_MIG_RAV_1019/1191_02","WAVE21_USCNTL_MIG_RAV_2702_01" ,"WAVE21_USENT_MIG_RAV_1003_05")



$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE21_USENT_MIG_RAV_1019/1191_02" ; Completed = "7"; Total = "7"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE21_USENT_MIG_RAV_1003_05" ; Completed = "1"; Total = "1"; MigState = 'Migrated'; MigrationPeriod = ""} 


$removeArray +=@("WAVE20_DEDMZ_MIG_RAV_3000_3012_02","WAVE20_DESEC_MIG_RAV_2048_50_2100_11","WAVE20_DEPROT_MIG_RAV_2409_12_32_62_2531_06","WAVE20_DESEC_MIG_RAV_2048_50_2150_2152_12")
$removeArray +=@("WAVE20_DESEC_MIG_RAV_2001_09","WAVE20_DESEC_MIG_RAV_2000_08","WAVE20_DESEC_MIG_RAV_2001_10","WAVE20_DESEC_MIG_RAV_2000_07" ,"WAVE20_DEPROT_MIG_COLD_2406_13")
$removeArray +=@("CTX_WAVE20_DEENT_MIG_BULK_1003_37__57_58_02")




$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE20_DEPROT_MIG_RAV_2409_12_32_62_2531_06" ; Completed = "9"; Total = "9"; MigState = 'Migrated'; MigrationPeriod = ""} 


$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE20_DESEC_MIG_RAV_2001_09" ; Completed = "18"; Total = "18"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE20_DESEC_MIG_RAV_2000_08" ; Completed = "15"; Total = "15"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE20_DESEC_MIG_RAV_2001_10" ; Completed = "17"; Total = "17"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE20_DESEC_MIG_RAV_2000_07" ; Completed = "13"; Total = "13"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE20_DEPROT_MIG_COLD_2406_13" ; Completed = "1"; Total = "1"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "CTX_WAVE20_DEENT_MIG_BULK_1003_37__57_58_02" ; Completed = "6"; Total = "6"; MigState = 'Migrated'; MigrationPeriod = ""} 




$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE19_DEDMZ_MIG_RAV_3000_3001_01" ; Completed = "8"; Total = "8"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE19_DEPROT_MIG_COLD_2400_05_06_16" ; Completed = "2"; Total = "2"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE19_DEPROT_MIG_RAV_2406_07_12" ; Completed = "23"; Total = "23"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "CTX_WAVE19_DEENT_MIG_BULK_1002_1056_05" ; Completed = "2"; Total = "2"; MigState = 'Migrated'; MigrationPeriod = ""} 



#>






$MGMigratedCount =0;
$ReplicatedCount =0;
$TotalMigrations = 0;
$TotalVMs = 0;
$TotalPercent = '0'
$migstarttime = 0
$migendtime =0
$Period = ""


$Wavefolder = $Wave.Replace(" ","_");
$TableData = ""


$SleepSeconds = 2;
$Output = "";
$WaveOutputFilPath = "C:\Temp\$Wavefolder\VMMigrated_email_" + $(Get-Date).ToString("yymmddHHmmssff") +  ".txt" 
#Note: Handle $Test carefully if set to false emails will go to email-list from database else set to $true
$Test= $true;
$ShowState = $false;




 
 # Sample data

 

#Connect-HCXServer -Server 10.30.164.2 -User 'sutenali' -Password 'UCkJ98}RPU2Yl*U[-?'
Write-Output "Connecting to  $Location.......$(Get-Date)"
if ($Location -eq 'US')  {
 
Connect-HCXServer -Server usd11HCXman -User 'HCXscriptUser@us-bcs.local' -Password 'Pa$$forCLI3000'

} else {

Connect-HCXServer -Server defrHCXman.bayer.cnb -User 'HCXscriptUser@de-bcs.local' -Password 'Pa$$forCLI3000'
}

   $mobilityGroups = Get-HCXMobilityGroup
   
    # Display retrieved Mobility Groups
   #$MGSets = $mobilityGroups  | Where-Object {$_.Name.ToUpper().Contains("WAVE10_US_MIG_RAV_1008_09")} 
   $MGSets = $mobilityGroups  | Where-Object {$_.Name.ToUpper().Contains($Wave.ToUpper())} 

   $MGSets = $MGSets | Where-Object {$_.Name -notin $removeArray}

ForEach ($MGSet in $MGSets) {
        #$MGSet

        $MGMigratedCount =0;
        $ReplicatedCount=0;
        $TotalMigrations =0;
        $migstarttime = 0
        $migendtime =0
        $Period = ""
        try {
            $TotalMigrations = $MGSet.TotalMigrations
            

            try {
            
              $mobilityGroup = Get-HCXMobilityGroup -Id $MGSet.Id -Detailed
             
                 if($mobilityGroup)  {
      
                       
                         foreach($migration in ($mobilityGroup.Migration | Sort-Object | Get-Unique)) {
                         #$migration
                         #$migration.MigrationGroupId

                         $vmsarray += [PSCustomObject]@{ MGSet = $MGSet.Name ;Server = $migration.Name ;}
                         $servers += [PSCustomObject]@{Server = $migration.Name ;}
                         
 
                         $MigratingServers = Get-HCXMigration  | Where-Object { ($_.VM.Name  -eq $migration.Name) -and ($_.MigrationGroupId -eq $migration.MigrationGroupId)}
                         $migstarttime = $MigratingServers.ScheduleStartTime
                         $migendtime = $MigratingServers.ScheduleEndTime
                          if ($migstarttime -eq  $null) {
                         $Period = ""
                         } else  {
                         $Period = $migstarttime.ToString() + ' - ' +  $migendtime.ToString() 
                         }
         
                         if ($ShowState) {
                            $MigratingServers.State + " " + $MigratingServers.MigrationGroupId
                         }


                             if ( $MigratingServers.State -eq  'MIGRATED') {
                             $MGMigratedCount +=1
                             } elseif ( $MigratingServers.State -eq 'WAITING_FOR_MAINTENANCE_WINDOW')  {
                             $ReplicatedCount +=1
                             } elseif ( $MigratingServers.State -eq 'CANCELED')  {
                                    $TotalMigrations-=1
                             }
                        }         
       
       
                       
      
                      }
       
                 }
        catch {
            Write-Host "Error occurred while retrieving HCX Mobility Groups."
    
            # Display exception message
            Write-Host "Exception: $($_.Exception.Message)"
    
            # Display inner exception details if present
            if ($_.Exception.InnerException) {
                Write-Host "Inner Exception: $($_.Exception.InnerException.Message)"
            }
        }

                        if ($ReplicatedCount -ge $MGMigratedCount){


                       

                            if ($ReplicatedCount -eq $TotalMigrations) {
                                 Write-Host " $MGSet : $ReplicatedCount of total  $TotalMigrations Replicated Scheduled times:  $Period " -ForegroundColor   Yellow 
                                 } 
                            else { 
                                    if ($MGMigratedCount -gt 0 ){
                                    # 1) Create a new set 
                                    # 2) Remove from total count
                                    $TotalMigrations -= $MGMigratedCount 
                                    $array += [PSCustomObject]@{Location = $Location ;MobilityGroup = $MGSet.Name + "*"; Completed = $MGMigratedCount; Total = $MGMigratedCount; MigState = 'Migrated'; MigrationPeriod = $Period} 
                                     Write-Host " $MGSet* : $MGMigratedCount of total  $MGMigratedCount Migrated Scheduled times:  $Period " -ForegroundColor Green
                                    
                                    }

                                  Write-Host " $MGSet : $ReplicatedCount of total  $TotalMigrations Replicated Scheduled times:  $Period " -ForegroundColor white
                                  }
                         
                         
                          $array += [PSCustomObject]@{Location = $Location ;MobilityGroup = $MGSet.Name ; Completed = $ReplicatedCount; Total = $TotalMigrations; MigState = 'Replicated'; MigrationPeriod = $Period} 
                         
                         }
                        else {
                        $array += [PSCustomObject]@{Location = $Location ;MobilityGroup = $MGSet.Name ; Completed = $MGMigratedCount; Total = $TotalMigrations; MigState = 'Migrated'; MigrationPeriod = $Period} 
                        #$MGSet.Name + ': ' + $MGMigratedCount +'  of total ' + $TotalMigrations + ' Migrated' + ' Scheduled times: ' + $Period
                            if ($MGMigratedCount -eq $TotalMigrations) {

                            Write-Host " $MGSet : $MGMigratedCount of total  $TotalMigrations Migrated Scheduled times:  $Period " -ForegroundColor  Green } 
                            else 
                            {  Write-Host " $MGSet : $MGMigratedCount of total  $TotalMigrations Migrated Scheduled times:  $Period " -ForegroundColor Magenta
                            }
                        }

         $PSDefaultParameterValues['Out-File:Width'] = 2000
         $array | select Location, MobilityGroup,Completed,Total,MigState, MigrationPeriod|export-csv  "C:\temp\MGSet_MigStats_data_dummy_$Location.csv" -Delimiter "|" -NoTypeInformation
        
        }
         catch {
          
            Write-Output $_.Exception.Message
            if ($_.Exception.InnerException) {
                Write-Host "Inner Exception: $($_.Exception.InnerException.Message)"
            }

        }
        # Retrieve the mobility group details
      $vmsarray  | select MGSet,Server |export-csv  "C:\temp\MGSet_servers_data_dummy_$Location.csv" -Delimiter "|" -NoTypeInformation
       
        

       
        
}

if ($Location -eq 'US')  {
    Disconnect-HCXServer -Server usd11HCXman -Confirm:$false
    $Data = Invoke-SQLCmd -ServerInstance BYUS226VXYE -Database "WavesDb" -Query “ exec spImportMGSet_Servers '$Wave' " -TrustServerCertificate 
    
}
else {
    Disconnect-HCXServer -Server defrHCXman.bayer.cnb -Confirm:$false

}
Write-Output "`nDisConnecting from  $Location .......$(Get-Date)"