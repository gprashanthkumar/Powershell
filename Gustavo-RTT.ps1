cls
$computername = $env:computername  
$computernameTarget =  "10.32.196.117" #  "10.32.196.106"   # "10.32.196.102" # 
$computerIPs = [System.Net.Dns]::GetHostAddresses($computername)  | where {$_.AddressFamily -notlike "InterNetworkV6"} | foreach {echo $_.IPAddressToString }
$computerIPsTarget = [System.Net.Dns]::GetHostAddresses($computernameTarget)  | where {$_.AddressFamily -notlike "InterNetworkV6"} | foreach {echo $_.IPAddressToString }
Write-Host "Running from Server:" $computername "with IP" $computerIPs  "`n"
Write-Host "Targeting the Server:" $computernameTarget "with IP" $computerIPsTarget  "at $datetime" "`n"

$ping = New-Object System.Net.NetworkInformation.Ping  

1..30 | ForEach-Object {  
         $ping.Send($computernameTarget, 1000, [byte[]](1..32), (New-Object System.Net.NetworkInformation.PingOptions -Property @{Ttl=$_; DontFragment=$true})) |      
           Select-Object @{Name='TTL';Expression={$_.Options.Ttl}}, @{Name='Address';Expression={$_.Address}}, @{Name='Status';Expression={$_.Status}}, @{Name='RoundtripTime';Expression={$_.RoundtripTime}} # | Format-Table -AutoSize  | Out-String | ForEach-Object { $_.TrimEnd() } | Out-String
       
}  