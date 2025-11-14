cls

$datetime =  Get-Date -Format "dddd dd/MM/yyyy HH:mmm fff" 
$computername = $env:computername  
$computernameTarget = "10.32.196.117" #"AVSPOPtestDB2"
$computerIPs = [System.Net.Dns]::GetHostAddresses($computername)  | where {$_.AddressFamily -notlike "InterNetworkV6"} | foreach {echo $_.IPAddressToString }
$computerIPsTarget = [System.Net.Dns]::GetHostAddresses($computernameTarget)  | where {$_.AddressFamily -notlike "InterNetworkV6"} | foreach {echo $_.IPAddressToString }
Write-Host "Running from Server:" $computername "with IP" $computerIPs  "`n"
Write-Host "Targeting the Server:" $computernameTarget "with IP" $computerIPsTarget  "at $datetime" "`n"

tracert $computernameTarget