cls

param(
    [string]$Wave,
    [string]$Location = "US"
	
)

# Output file
$OutputPath = "C:\Temp\$($Wave.Replace(' ','_'))_MigrationReport.csv"




# Connect to HCX Manager
$server = if ($Location -eq 'US') { 'usd11HCXman' } else { 'defrHCXman.bayer.cnb' }
$user   = if ($Location -eq 'US') { 'HCXscriptUser@us-bcs.local' } else { 'HCXscriptUser@de-bcs.local' }
$pass   = if ($Location -eq 'US') { 'Pa$$forCLI3001' } else { 'Pa$$forCLI3000' }

Write-Output "Connecting to $Location HCX Manager..."
Connect-HCXServer -Server $server -User $user -Password $pass



Write-Output "Migration report saved to $OutputPath"

Disconnect-HCXServer -Confirm:$false

