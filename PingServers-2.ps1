cls;
Import-Module "C:\temp\Get-MACAddress.ps1"

$computername = $env:computername  
$computerIPs = [System.Net.Dns]::GetHostAddresses($computername)  | where {$_.AddressFamily -notlike "InterNetworkV6"} | foreach {echo $_.IPAddressToString }
$datetime =  Get-Date -Format "dddd dd/MM/yyyy HH:mm K"
Write-Host "Running from Server:" $computername "with IP" $computerIPs  "at $datetime"
$computers = Get-Content -Path "C:\temp\ListOfComputerIPs-Wave2.txt"
$upCount = 0; 
$downCount = 0;
foreach ($computer in $computers)
    {
    $ip = $computer.Split(" - ")[0]
    $computernameTarget = $ip
      
    
    if (Test-Connection  $ip -Count 1 -ErrorAction SilentlyContinue){
        $upCount +=1;
        $computerIPsTarget = [System.Net.Dns]::GetHostAddresses($computernameTarget)  | where {$_.AddressFamily -notlike "InterNetworkV6"} | foreach {echo $_.IPAddressToString }
        Write-Host "$computernameTarget with  IP Address: $computerIPsTarget  is up" -ForegroundColor Green
        }
    else{
        $downCount +=1;
        Write-Host "$ip is down" -ForegroundColor Red
        }
    }
    $total = ($upCount +$downCount);
    Write-Host "Total servers Scanned:$total with $upCount up while $downCount are down" -ForegroundColor white
    
