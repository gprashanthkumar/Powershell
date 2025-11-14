cls

param(
    [string]$Wave,
    [string]$Location = "US",
[string]$Location1 = "DE"
	
)

# Output file
$OutputPath = "C:\Temp\$($Wave.Replace(' ','_'))_MigrationReport.csv"




# Connect to HCX Manager
$server = if ($Location -eq 'US') { 'usd11HCXman' } else { 'defrHCXman.bayer.cnb' }
$user   = if ($Location -eq 'US') { 'HCXscriptUser@us-bcs.local' } else { 'HCXscriptUser@de-bcs.local' }
$pass   = if ($Location -eq 'US') { 'Pa$$forCLI3001' } else { 'Pa$$forCLI3000' }

Write-Output "Connecting to $Location HCX Manager..."
Connect-HCXServer -Server $server -User $user -Password $pass

# Patterns
$CitrixPattern = 'CTX'
$WeblogicPattern = 'WEBL'

# Fetch migrations for the wave
$migrations = Get-HCXMobilityGroup |
              Where-Object { $_.Name -like "*$Wave*" } |
              ForEach-Object {
                  foreach ($mig in $_.Migration) {
                      [PSCustomObject]@{
                          VMName            = $mig.Name
                          Type              = if ($mig.Name -match $CitrixPattern) { 'Citrix' } else { 'Other' }
                          MigrationApproach = if ($mig.MigrationType) { $mig.MigrationType } else {
                              if ($_.Name -match 'RAV') { 'RAV' }
                              elseif ($_.Name -match 'ONLINE') { 'Online' }
                              elseif ($_.Name -match 'COLD') { 'Cold' }
                              else { 'Bulk' }
                          }
                          Wave              = $Wave
                          Citrix_Weblogic   = if ($mig.Name -match $CitrixPattern) { 'Citrix' } elseif ($mig.Name -match $WeblogicPattern) { 'Weblogic' } else { 'Other' }
                          ServerName        = $mig.Name
                          Location          = $Location
                      }
                  }
              }

# Export to CSV
$migrations | Export-Csv -Path $OutputPath -NoTypeInformation

Write-Output "Migration report saved to $OutputPath"

Disconnect-HCXServer -Confirm:$false

.\HCXMigrationReport.ps1 -Wave "Wave30_USENT_MIG" -Location "U
