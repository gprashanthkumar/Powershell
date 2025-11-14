cls

Connect-HCXServer -Server usd11HCXman -User 'HCXscriptUser@us-bcs.local' -Password 'Pa$$forCLI2001'

write-host(“Import csv details for the VMs to be migrated”)
$HCXVMS = Import-CSV "C:\Temp\Wave2\Wave2-MobilityGroup_full.csv"
#$HCXVMS
$counter = 1;
$PoweredOff = 0;
$PoweredOffServers= ""
$MultiNetworkServers= ""
$NotFoundServers= ""

ForEach ($HCXVM in $HCXVMS) {


     try {
             Write-Output " ------ VM:$counter - $($($HCXVM.VM_NAME).ToLower())  ------"
             $vm = Get-HCXVM -Name $HCXVM.VM_NAME -ErrorAction SilentlyContinue
             if (!$vm) {
              $vm = Get-HCXVM -Name $($HCXVM.VM_NAME).ToLower()

                if (!$vm) {
                $NotFoundServers += $($HCXVM.VM_NAME).ToLower() + ","
                }
              
             }
             
             #$vm

             if ($vm.PowerState  -eq  'PoweredOff') {
             
             $PoweredOffServers += $vm.Name + ','
             $PoweredOff+=1
             
             }
             if ($vm.Network.Count>1) {
             $MultiNetworkServers += $vm.Name + "-" + $vm.Network.ToString() + ','
              $vm
             }
         
        }

        catch {
           Write-Host "vm Failed- $HCXVM.VM_NAME -------------------------"
           Write-Host $_.Exception.Message

        }
    

    #$vm.Site.Name
            
    


$counter +=1;
}

Disconnect-HCXServer -Server usd11HCXman -Confirm:$false
Write-Host "VM's PoweredOff Count: $PoweredOff"
 
Write-Host "VM's Powered Off: $PoweredOffServers"

Write-Host "VM's Multinetworks: $MultiNetworkServers"

Write-Host "VM's not found: $NotFoundServers"



