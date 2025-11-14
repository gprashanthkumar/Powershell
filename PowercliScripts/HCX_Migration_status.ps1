cls


# Initialize an empty array
$array = @()
 
 # Sample data

 

#Connect-HCXServer -Server 10.30.164.2 -User 'sutenali' -Password 'UCkJ98}RPU2Yl*U[-?'
Connect-HCXServer -Server usd11HCXman -User 'HCXscriptUser@us-bcs.local' -Password 'Pa$$forCLI2001'

$filterDate =  [DateTime]"2025-Apr-11"



$MigratingServers = Get-HCXMigration  -MigrationType RAV   | Where-Object {$_.StartTime.Date -ge $filterDate}
 foreach($migration in $MigratingServers) {
 

$vm = $migration.VM
$UId = $migration.Uid
$MigState = $migration.State
$migstart = $migration.StartTime
$migendtime = $migration.EndTime

# Add objects to the array
$array += [PSCustomObject]@{Server = $migration.VM ; UID = $migration.Uid; Percentage = $migration.Percentage ;MigState = $migration.State; migstart = $migration.StartTime ;migendtime = $migration.EndTime} 

#Write-Host (" Server: $vm  with UDID: $UId going with state $MigState that started on $migstart and ending on $migendtime");
}
$PSDefaultParameterValues['Out-File:Width'] = 2000



# Print the array
#$array | select server, percentage,MigState, migstart,migendtime ,uid| Format-Table | Out-File  'C:\temp\HCXMigation_data_20250402.txt' -Delimiter "|"
$array | select server, percentage,MigState, migstart,migendtime ,uid |export-csv  'C:\temp\HCXMigation_data_dummy.csv' -Delimiter "|" -NoTypeInformation


Disconnect-HCXServer -Server usd11HCXman -Confirm:$false

#$MigratingServers

$Data = Invoke-SQLCmd -ServerInstance BYUS226VXYE -Database "WavesDb" -Query “ exec spImportHCXMigration_VM_Status " -TrustServerCertificate 

#Execute-Stored-Procedure -server "BYUS226VXYE" -db "WavesDB" -spname "spImportHCXMigration_VM_Status"

$array  |Group-Object MigState 
