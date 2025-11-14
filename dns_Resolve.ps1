cls
$output =@()
$output1 =@()
$computername = $env:computername  
$DNScomputers = @("usd11-runipap01.dnsrv.cnb", "usva3-runipap01.dnsrv.cnb" ,"GWEAVDAD03PR010.bayer.cnb", "GWEAVDAD03PR010i.bayer.cnb")
$computerIPs = [System.Net.Dns]::GetHostAddresses($computername)  | where {$_.AddressFamily -notlike "InterNetworkV6"} | foreach {echo $_.IPAddressToString }

$datetime =  Get-Date -Format "dddd dd/MM/yyyy HH:mmm fff"
$dd  = $datetime.ToString()
Write-Host "Running from Server: $computername  with IP:  $computerIPs  at $dd `n"


foreach ($computernameTarget in $DNScomputers)
    {
      
        try {
            $result = Resolve-DnsName -Name $computernameTarget -ErrorAction Stop
            $result1 = nslookup $computernameTarget 2>&1         
            
            
           
            
            $output += [pscustomobject]@{
                Server     = $result.Name
                "IP Address"       = $result.IPAddress
               
                "DNS Server" = $result1
                 Status   = "Successfull: " + $result.Name
              
            } 
        } catch {
            $output += [pscustomobject]@{
                Server     = $computernameTarget
                "IP Address"       = ""
                 "DNS Server" = $result1
                Status   = "Failure: " + $_.Exception.Message  + ": NXDOMAIN"
            }
        }

       
    }
    
     
     
     $output | format-List
