cls
$Location  = "US"
if ($Location -eq 'US')  {
 Write-Output "Connecting to  $Location ......."
Connect-VIServer -Server  usd11-bcsvvc001 -User 'HCXscriptUser@us-bcs.local' -Password 'Pa$$forCLI3001'
#Connect-VIServer -Server usd11-bcsvvc001.bmsinfra.net -User 'pragarla' -Password 'Mar@thu@20252025'

} else {
Write-Output "Connecting to  $Location......."
Connect-HCXServer -Server defrHCXman.bayer.cnb -User 'HCXscriptUser@de-bcs.local' -Password 'Pa$$forCLI3000'
}

write-host(“Import csv details for the VMs to be migrated”)
#$HCXVMS = Import-CSV "C:\Temp\Floppy_US.csv"
$HCXVMS = Import-CSV "C:\Temp\Floppy_US.csv"
$FloppyVMs = @()



 $PoweredOffServers = $null
 $counter = 1

 #$HCXVMS 

 

ForEach ($HCXVM in $HCXVMS) {
#$HCXVM

 $vm  = $null

     try {
             Write-Output " ------ VM:$counter - $($($HCXVM.VMName).ToLower())  ------"
                     $vm  = $null
                     #$vm = Get-HCXVM -Name $HCXVM.VMName  #-ErrorAction SilentlyContinue
                     $vms = Get-VM -Name $HCXVM.VMName  #-ErrorAction SilentlyContinue
                     $vm

                     if (!$vm) {
                      #$vm = Get-HCXVM -Name $($HCXVM.VMName).ToLower()
                      $vm = Get-VM -Name $($HCXVM.VMName).ToLower()

                      if (!$vm) {
                        $NotFoundServers += $($HCXVM.VMName).ToLower() + ","
                        }
                       else { 

                                    
                                if ($vm.PowerState  -eq  'PoweredOff') {
             
                                 $PoweredOffServers += $vm.Name + ','
                                 $PoweredOff+=1
             
                                 }

                       }

                       

                     }
                     # vm is loaded
                     if ($vm) {                     
                       
                        Write-output "Server is in VCenter:   " + $vm.Name
                        $FloppyVMs += $vm.Name
                         Write-output "--------------------------- " 
                        $floppyDrives = Get-FloppyDrive -VM $vm
                        $floppyDrives
                        
                         Write-output "<---------------------------> " 
                       }
                       
             } #try 
     catch {
           Write-Host "vm Failed- $HCXVM.VM_NAME -------------------------"
           Write-Host $_.Exception.Message

        }
        $counter +=1;
}


$FloppyVMs  | Out-File -FilePath "C:\Temp\PowercliScripts\FloopyDrive\USVcentreVMs.txt"

if ($Location -eq 'US')  {
    Disconnect-VIServer -Server usd11-bcsvvc001 -Confirm:$false    
    
}
else {
    Disconnect-HCXServer -Server defrHCXman.bayer.cnb -Confirm:$false

}
Write-Output "`nDisconnecting from  $Location.......$(Get-Date)"
