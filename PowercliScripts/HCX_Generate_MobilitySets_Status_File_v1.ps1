cls


# Initialize an empty array
$array = @()
$Location  = "US"
$MGMigratedCount =0;
$TotalVMs = 0;
$TotalPercent = '0'
$migstarttime = 0
$migendtime =0

$Wave = "Wave5"
$Wavefolder = $Wave.Replace(" ","_");
$MGSets = Get-Content -Path "C:\Temp\$Wavefolder\Wave-MGSet.txt"

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
Write-Output "Connecting to  DE......."
Connect-HCXServer -Server defrHCXman.bayer.cnb -User 'HCXscriptUser@de-bcs.local' -Password 'Pa$$forCLI2001'
}



ForEach ($MGSet in $MGSets) {


        # Retrieve the mobility group details
        $mobilityGroup = Get-HCXMobilityGroup -Name $MGSet -Detailed
        #$mobilityGroup
       $MGMigratedCount =0;
        $migstarttime = 0
        $migendtime =0
        #$MigratingServers = Get-HCXMigration  -MigrationType RAV   | Where-Object {$_.StartTime.Date -ge $filterDate}
         foreach($migration in $mobilityGroup.Migration) {
 
         $MigratingServers = Get-HCXMigration  -MigrationType RAV   | Where-Object {$_.VM.Name  -eq $migration.Name}
         $migstarttime = $MigratingServers.ScheduleStartTime
         $migendtime = $MigratingServers.ScheduleEndTime
             if ( $MigratingServers.State -eq  'MIGRATED') {
             $MGMigratedCount +=1
             

             }
        }
        $array += [PSCustomObject]@{Location = $Location ;MobilityGroup = $mobilityGroup.Name ; Completed = $MGMigratedCount; Total = $mobilityGroup.TotalMigrations; MigState = 'Migrated'; MigrationPeriod = $migstarttime.ToShortDateString() + ' - ' + $migendtime.ToShortDateString()} 
       
        $mobilityGroup.Name + ': ' + $MGMigratedCount +'  of total ' + $mobilityGroup.TotalMigrations + ' Migrated' + ' Scheduled times: ' + $migstarttime + ' - ' + $migendtime
        $PSDefaultParameterValues['Out-File:Width'] = 2000

       
 
        $array | select Location, MobilityGroup,Completed,Total,MigState, MigrationPeriod|export-csv  "C:\temp\MGSet_MigStats_data_dummy_$Location.csv" -Delimiter "|" -NoTypeInformation
        
}

if ($Location -eq 'US')  {
    Disconnect-HCXServer -Server usd11HCXman -Confirm:$false
    
}
else {
    Disconnect-HCXServer -Server defrHCXman.bayer.cnb -Confirm:$false

}