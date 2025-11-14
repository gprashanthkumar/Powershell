 
cls

function Measure-TCPConnectionHighPrecision {  

    param(  

        [string]$hostname,  

        [int]$port  

    )  

    #Add-Type -AssemblyName System.Net.Sockets  
    #Add-Type -AssemblyName System.Net.Sockets.TcpClient  
    #Add-Type -AssemblyName System.Net


    $tcpClient = New-Object System.Net.Sockets.TcpClient  

    $stopwatch = New-Object System.Diagnostics.Stopwatch  

    try {  

        $stopwatch.Start()  

        $tcpClient.ConnectAsync($hostname, $port).Wait()  

        $stopwatch.Stop()  

        if ($tcpClient.Connected) {  

            $status = "Connected"  

            $tcpClient.Close()  

        } else {  

            $status = "Failed to connect"  

        }  

    } catch {  

        $status = "Error"  

        $stopwatch.Stop()  

    } finally {  

        if ($tcpClient.Connected) {  

            $tcpClient.Close()  

        }  

    }  

    return [PSCustomObject]@{  

        Hostname = $hostname  

        Port = $port  

        Status = $status  

        TimeTakenMs = $stopwatch.Elapsed.TotalMilliseconds  

        TimeTakenTicks = $stopwatch.Elapsed.Ticks  # 1 tick = 100 nanoseconds  

    }  

}  
$datetime =  Get-Date -Format "dddd dd/MM/yyyy HH:mmm fff" 
$computername = $env:computername  
$computernameTarget =  "10.32.196.102" # "10.32.196.117" #   "10.32.196.106" # 
$computerIPs = [System.Net.Dns]::GetHostAddresses($computername)  | where {$_.AddressFamily -notlike "InterNetworkV6"} | foreach {echo $_.IPAddressToString }
$computerIPsTarget = [System.Net.Dns]::GetHostAddresses($computernameTarget)  | where {$_.AddressFamily -notlike "InterNetworkV6"} | foreach {echo $_.IPAddressToString }
Write-Host "Running from Server:" $computername "with IP" $computerIPs  "`n"
Write-Host "Targeting the Server:" $computernameTarget "with IP" $computerIPsTarget  "at $datetime" "`n"


Measure-TCPConnectionHighPrecision -hostname $computernameTarget -port 1521  # Adjust the port if SQL Server listens on a different one"
 