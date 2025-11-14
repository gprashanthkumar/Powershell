$computers = Get-Content -Path "C:\temp\ListOfComputersIP-Wave10.txt"
foreach ($computer in $computers)
    {
    $ip = $computer.Split(" - ")[0]
    if (Test-Connection  $ip -Count 1 -ErrorAction SilentlyContinue){
        Write-Host "$ip is up" -ForegroundColor Green
        }
    else{
        Write-Host "$ip is down" -ForegroundColor Red
        }
    }