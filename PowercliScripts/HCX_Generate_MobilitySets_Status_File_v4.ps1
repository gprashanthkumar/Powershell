cls


# Initialize an empty array
$array = @()
$servers = @()
$vmsarray = @()
$Location  = "US"
$removeArray =@("WAVE9_US_MIG_RAV_1005_04")
#$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE9_US_MIG_RAV_1005_04" ; Completed = "1"; Total = "1"; MigState = 'Migrated'; MigrationPeriod = "6/16/2025 4:46:00 AM - 6/20/2025 3:46:00 PM"} 
#$array += [PSCustomObject]@{Location = $Location ;MobilityGroup = "WAVE6B_DE_MIG_RAV_1192_04" ; Completed = "0"; Total = "11"; MigState = 'Replicated'; MigrationPeriod = ""} 

$MGMigratedCount =0;
$ReplicatedCount =0;
$TotalMigrations = 0;
$TotalVMs = 0;
$TotalPercent = '0'
$migstarttime = 0
$migendtime =0
$Period = ""

$Wave = "WAVE10"
$Wavefolder = $Wave.Replace(" ","_");
$TableData = ""


$SleepSeconds = 2;
$Output = "";
$WaveOutputFilPath = "C:\Temp\$Wavefolder\VMMigrated_email_" + $(Get-Date).ToString("yymmddHHmmssff") +  ".txt" 
#Note: Handle $Test carefully if set to false emails will go to email-list from database else set to $true
$Test= $true;




 
 # Sample data

 

#Connect-HCXServer -Server 10.30.164.2 -User 'sutenali' -Password 'UCkJ98}RPU2Yl*U[-?'
if ($Location -eq 'US')  {
 Write-Output "Connecting to  $Location ......."
Connect-HCXServer -Server usd11HCXman -User 'HCXscriptUser@us-bcs.local' -Password 'Pa$$forCLI2001'

} else {
Write-Output "Connecting to  $Location......."
Connect-HCXServer -Server defrHCXman.bayer.cnb -User 'HCXscriptUser@de-bcs.local' -Password 'Pa$$forCLI2001'
}

   $mobilityGroups = Get-HCXMobilityGroup
   
    # Display retrieved Mobility Groups
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
      
                       #$MigratingServers = Get-HCXMigration  -MigrationType RAV   | Where-Object {$_.StartTime.Date -ge $filterDate}
                         foreach($migration in ($mobilityGroup.Migration | Sort-Object | Get-Unique)) {
                         $vmsarray += [PSCustomObject]@{ MGSet = $MGSet.Name ;Server = $migration.Name ;}
                         $servers += [PSCustomObject]@{Server = $migration.Name ;}
 
                         $MigratingServers = Get-HCXMigration  | Where-Object {$_.VM.Name  -eq $migration.Name}
                         $migstarttime = $MigratingServers.ScheduleStartTime
                         $migendtime = $MigratingServers.ScheduleEndTime
                          if ($migstarttime -eq  $null) {
                         $Period = ""
                         } else  {
                         $Period = $migstarttime.ToString() + ' - ' +  $migendtime.ToString() 
                         }
         
                         #$MigratingServers.State

                             if ( $MigratingServers.State -eq  'MIGRATED') {
                             $MGMigratedCount +=1
                             } elseif ( $MigratingServers.State -eq 'WAITING_FOR_MAINTENANCE_WINDOW')  {
                             $ReplicatedCount +=1
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
                         $MGSet.Name + ': ' + $ReplicatedCount +'  of total ' + $TotalMigrations + ' Replicated' + ' Scheduled times: ' + $Period
                        }
                        else {
                        $array += [PSCustomObject]@{Location = $Location ;MobilityGroup = $MGSet.Name ; Completed = $MGMigratedCount; Total = $TotalMigrations; MigState = 'Migrated'; MigrationPeriod = $Period} 
                        $MGSet.Name + ': ' + $MGMigratedCount +'  of total ' + $TotalMigrations + ' Migrated' + ' Scheduled times: ' + $Period
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