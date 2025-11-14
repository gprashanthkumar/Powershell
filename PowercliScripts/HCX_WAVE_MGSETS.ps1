cls


# $mobilityGroup = Get-HCXMobilityGroup -Name "WAVE5_US_MIG_RAV_1001_01" -Detailed
#Disconnect-HCXServer -Server usd11HCXman -Confirm:$false



try {
    # Connect to HCX server (Replace with appropriate credentials)
    Connect-HCXServer -Server usd11HCXman -User 'HCXscriptUser@us-bcs.local' -Password 'Pa$$forCLI2001'


    # Attempt to retrieve HCX Mobility Groups
    $mobilityGroups = Get-HCXMobilityGroup

    # Display retrieved Mobility Groups
    $mobilityGroups  | Where-Object {$_.Name.Contains("WAVE5_US_MIG_RAV_1001_01")} | Format-Table -AutoSize

}
catch {
    Write-Host "Error occurred while retrieving HCX Mobility Groups."
    
    # Display exception message
    Write-Host "Exception: $($_.Exception.Message)"
    
    # Display inner exception details if present
    if ($_.Exception.InnerException) {
        Write-Host "Inner Exception: $($_.Exception.InnerException.Message)"
    }
}finally {

  Disconnect-HCXServer -Server usd11HCXman -Confirm:$false
  }
