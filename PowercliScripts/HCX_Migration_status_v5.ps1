cls


# Initialize an empty array
$array = @()
$Location  = "US"
 
 # Sample data

 

#Connect-HCXServer -Server 10.30.164.2 -User 'sutenali' -Password 'UCkJ98}RPU2Yl*U[-?'
if ($Location -eq 'US')  {
 Write-Output "Connecting to  US.......$(Get-Date)"
Connect-HCXServer -Server usd11HCXman -User 'HCXscriptUser@us-bcs.local' -Password 'Pa$$forCLI3000'

} else {
Write-Output "Connecting to  DE.......$(Get-Date)"
Connect-HCXServer -Server defrHCXman.bayer.cnb -User 'HCXscriptUser@de-bcs.local' -Password 'Pa$$forCLI3000'
}


$filterDate =  [DateTime]"2025-11-01"



$MigratingServers = Get-HCXMigration  -MigrationType RAV   | Where-Object {$_.StartTime.Date -ge $filterDate}
 foreach($migration in $MigratingServers) {
 

$vm = $migration.VM
$UId = $migration.Uid
$MigState = $migration.State
$migstart = $migration.StartTime
$migendtime = $migration.EndTime

# Add objects to the array
$array += [PSCustomObject]@{LOC =$Location; Server = $migration.VM ; UID = $migration.Uid; Percentage = $migration.Percentage; MigType = "RAV" ;MigState = $migration.State; migstart = $migration.StartTime ;migendtime = $migration.EndTime} 

#Write-Host (" Server: $vm  with UDID: $UId going with state $MigState that started on $migstart and ending on $migendtime");
}
$MigratingServers = Get-HCXMigration  | Where-Object {$_.StartTime.Date -ge $filterDate}
$MigratingServers = $MigratingServers | Where-Object {$_.MigrationType -eq 'ColdMigration'}


 foreach($migration in $MigratingServers) {
 

$vm = $migration.VM
$UId = $migration.Uid
$MigState = $migration.State
$migstart = $migration.StartTime
$migendtime = $migration.EndTime

# Add objects to the array
$array += [PSCustomObject]@{LOC =$Location; Server = $migration.VM ; UID = $migration.Uid; Percentage = $migration.Percentage ;MigType = "Cold";MigState = $migration.State; migstart = $migration.StartTime ;migendtime = $migration.EndTime} 

#Write-Host (" Server: $vm with UDID: $UId going with state $MigState that started on $migstart and ending on $migendtime");
Write-Host  "Cold COLD--------------------"
}



$MigratingServers = Get-HCXMigration  -MigrationType Bulk   | Where-Object {$_.StartTime.Date -ge $filterDate}
 foreach($migration in $MigratingServers) {
 

            $vm = $migration.VM
            $UId = $migration.Uid
            $MigState = $migration.State
            $migstart = $migration.StartTime
            $migendtime = $migration.EndTime

            # Add objects to the array
            $array += [PSCustomObject]@{LOC =$Location; Server = $migration.VM ; UID = $migration.Uid; Percentage = $migration.Percentage; MigType = "Bulk" ;MigState = $migration.State; migstart = $migration.StartTime ;migendtime = $migration.EndTime} 

            #Write-Host (" Server: $vm  with UDID: $UId going with state $MigState that started on $migstart and ending on $migendtime");
    }






$PSDefaultParameterValues['Out-File:Width'] = 2000



# Print the array
#$array | select server, percentage,MigState, migstart,migendtime ,uid| Format-Table | Out-File  'C:\temp\HCXMigation_data_20250402.txt' -Delimiter "|"
$array | select LOC, server,MigType, percentage,MigState, migstart,migendtime ,uid |export-csv  'C:\temp\HCXMigation_data_dummy.csv' -Delimiter "|" -NoTypeInformation


Write-Output "Disconnecting from US.......$(Get-Date)"

if ($Location -eq 'US')  {
    Disconnect-HCXServer -Server usd11HCXman -Confirm:$false

    #$MigratingServers
    $Data = Invoke-SQLCmd -ServerInstance BYUS226VXYE -Database "WavesDb" -Query “ exec spImportHCXMigration_VM_Status " -TrustServerCertificate 

    #Execute-Stored-Procedure -server "BYUS226VXYE" -db "WavesDB" -spname "spImportHCXMigration_VM_Status"
}
else {
    Disconnect-HCXServer -Server defrHCXman.bayer.cnb -Confirm:$false

}

$array  |Group-Object MigState 
Write-Output "dis connecting from $Location ......$(Get-Date)"
