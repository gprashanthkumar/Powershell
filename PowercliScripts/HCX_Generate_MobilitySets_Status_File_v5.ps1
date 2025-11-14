cls


# Initialize an empty array
$Wave = "Wave20"
$array = @()
$servers = @()
$vmsarray = @()
$Location  = "US"
$removeArray =@()

$removeArray =@("LVM_WAVE20_USSEC_2000_1","WAVE20_USSECU_MIG_RAV_2000/01/2150_04")
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "LVM_WAVE20_USSEC_2000_1" ; Completed = "1"; Total = "1"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE20_USSECU_MIG_RAV_2000/01/2150_04" ; Completed = "6"; Total = "6"; MigState = 'Migrated'; MigrationPeriod = ""} 


<#


$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE19_USPROT_MIG_RAV_2271_2400_04" ; Completed = "18"; Total = "18"; MigState = 'Migrated'; MigrationPeriod = ""} 
#$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE19A_USENT_MIG_RAV_1019_03" ; Completed = "4"; Total = "4"; MigState = 'Migrated'; MigrationPeriod = ""} 
#$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE19A_USDMZ_MIG_RAV_3001_02" ; Completed = "6"; Total = "6"; MigState = 'Migrated'; MigrationPeriod = ""} 
#$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE19A_USCON_MIG_RAV_2700_2701_01" ; Completed = "22"; Total = "22"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "CTX_WAVE19_USENT_MIG_RAV_1002_08_02" ; Completed = "3"; Total = "3"; MigState = 'Migrated'; MigrationPeriod = ""} 
$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE19_USENT_MIG_RAV_1002_08_02" ; Completed = "2"; Total = "2"; MigState = 'Migrated'; MigrationPeriod = ""} 






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
Connect-HCXServer -Server usd11HCXman -User 'HCXscriptUser@us-bcs.local' -Password 'Pa$$forCLI3001'

} else {

Connect-HCXServer -Server defrHCXman.bayer.cnb -User 'HCXscriptUser@de-bcs.local' -Password 'Pa$$forCLI3000'
}

   $mobilityGroups = Get-HCXMobilityGroup
   
    # Display retrieved Mobility Groups
   #$MGSets = $mobilityGroups  | Where-Object {$_.Name.ToUpper().Contains("WAVE13_USCTL_MIG_RAV_2701_02")} 
   $MGSets = $mobilityGroups  | Where-Object {$_.Name.ToUpper().Contains($Wave.ToUpper())} 

   $MGSets = $MGSets | Where-Object {$_.Name -notin $removeArray}

ForEach ($MGSet in $MGSets) {
        $MGSet.Name

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
      
                       #$MigratingServers = Get-HCXMigration  -MigrationType RAV   | Where-Object {$_.StartTime.Date -ge $filterDate}
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
         
                         if($ShowState) {
                         $MigratingServers.State + '----' + $MigratingServers.MigrationGroupId
                         }


                             if ( $MigratingServers.State -eq  'MIGRATED') {
                             $MGMigratedCount +=1
                             } elseif ( $MigratingServers.State -eq 'WAITING_FOR_MAINTENANCE_WINDOW')  {
                             $ReplicatedCount +=1
                             } elseif ( $MigratingServers.State -eq 'CANCELED')  {
                             
                                    #$MigratingServers
                                     $TotalMigrations

                                    $TotalMigrations-=1
                                    $TotalMigrations
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
                        $array += [PSCustomObject]@{Location = $Location ;MobilityGroup = $MGSet.Name ; Completed = $ReplicatedCount; Total = $TotalMigrations; MigState = 'Replicated'; MigrationPeriod = $Period} 
                            if ($ReplicatedCount -eq $TotalMigrations) {
                                 Write-Host " $MGSet : $ReplicatedCount of total  $TotalMigrations Replicated Scheduled times:  $Period " -ForegroundColor   Yellow } 
                            else { 
                                  Write-Host " $MGSet : $ReplicatedCount of total  $TotalMigrations Replicated Scheduled times:  $Period " -ForegroundColor Cyan}
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
Write-Output "`nDisconnecting from  $Location.......$(Get-Date)"