
Write-Output "Connecting to HCX Manager..."
Connect-HCXServer -Server usd11HCXman -User 'HCXscriptUser@us-bcs.local' -Password 'Pa$$forCLI3000'


# Get all migrations
$migrations = Get-HCXMigration

# Select only VM Name and Migration Type
$migrations | Select-Object VM, MigrationType |
    Export-Csv -Path "C:\Temp\HCX_VM_MigrationType.csv" -NoTypeInformation

Write-Output "CSV created at C:\Temp\HCX_VM_US_MigrationType.csv"


Disconnect-HCXServer -Confirm:$false
