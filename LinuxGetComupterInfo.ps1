   # PowerShell Script to Collect Linux System Info
   function Invoke-LinuxGetComputerInfo {
       param (
           [string]$HostName,
           [string]$Username,
           [string]$Password,
           [string]$Port
           )
       Invoke-SSH-Script -Host $HostName -Username $Username -Password $Password -Port $Port -Command "Get-ComputerInfo"
   }

   # Invoke the Function
   $hostName = "BYDE005JAR3"
   $userName = "ebedc"
   $password = "uh5vPKnLOcwXY@" # Use a key based authentication if possible for security instead of a password
   $port = "22" #Default SSH port

   Invoke-LinuxGetComputerInfo -HostName $hostName -Username $userName -Password $password -Port $port


   # Sample Script to Print Out Results
   Invoke-SSH -Host $hostName -Username $userName -Password $password -Port $port -Command "cat /etc/os-release"
   # OR
   Invoke-SSH -Host $hostName -Username $userName -Password $password -Port $port -Command "uname -a"
   #OR
   Invoke-SSH -Host $hostName -Username $userName -Password $password -Port $port -Command "lscpu"
    
   
   #last boot time
   Invoke-SSH -Host $hostName -Username $userName -Password $password -Port $port -Command "last reboot | head -1"
   
   #disk info
   Invoke-SSH -Host $hostName -Username $userName -Password $password -Port $port -Command "df -h"
   
   #disk info2
   Invoke-SSH -Host $hostName -Username $userName -Password $password -Port $port -Command "lsblk"
   
   #network info
   Invoke-SSH -Host $hostName -Username $userName -Password $password -Port $port -Command "ifconfig"
   
   #network info 2
   Invoke-SSH -Host $hostName -Username $userName -Password $password -Port $port -Command "ip addr"
   
   #https://github.com/ehmiiz/linuxinfo/tree/main