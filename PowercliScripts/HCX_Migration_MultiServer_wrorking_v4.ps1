cls
$Location = 'US'

if ($Location -eq 'US') {
#US
Connect-HCXServer -Server usd11HCXman -User 'HCXscriptUser@us-bcs.local' -Password 'Pa$$forCLI2001'
}  else 
{

#DE
#Connect-HCXServer -Server 10.30.166.2 -User 'HCXscriptUser@de-bcs.local' -Password 'Pa$$forCLI2001'
Connect-HCXServer -Server defrHCXman.bayer.cnb -User 'HCXscriptUser@de-bcs.local' -Password 'Pa$$forCLI2001'
}

write-host(“Import csv details for the VMs to be migrated”)
$HCXVMS = Import-CSV "C:\Temp\Wave4\Wave4-HCX-US.csv"

#$HCXVMS
$counter = 1;
$PoweredOff = 0;
$PoweredOffServers= ""
$MultiNetworkServers= ""
$NotFoundServers= ""


ForEach ($HCXVM in $HCXVMS) {



     try {
             Write-Output " ------ VM:$counter - $($($HCXVM.SERVER_NAME).ToLower())  ------"
              Write-Output " ------ VM:SOURCE_PORTGROUP - $($($HCXVM.SOURCE_SITE).ToLower())  ------"
               Write-Output " ------ VM:DEST_SITE - $($($HCXVM.DEST_SITE).ToLower())  ------"
                Write-Output " ------ VM:DEST_PORTGROUP - $($($HCXVM.DEST_PORTGROUP).ToLower())  ------"
                 Write-Output " ------ VM:ESX_SERVER - $($($HCXVM.ESX_SERVER).ToLower())  ------"
                  Write-Output " ------ VM:ESX_SERVER - $($($HCXVM.DEST_DATASTORE).ToLower())  ------"
             $vm  = $null
             $vm = Get-HCXVM -Name $HCXVM.SERVER_NAME -ErrorAction SilentlyContinue
            
                       
             if (!$vm) {
              $vm = Get-HCXVM -Name $($HCXVM.SERVER_NAME).ToLower()
              }
             
              if (!$vm) {
                $NotFoundServers += $($HCXVM.SERVER_NAME).ToLower() + ","
                 Write-Output "vm not found: $HCXVM.SERVER_NAME -"
                }
               else {
                         $vm 
               
                        if ($vm.PowerState  -eq  'PoweredOff') {
             
                         Write-Output "VM Powered Off: " + $HCXVM.SERVER_NAME
                         $PoweredOffServers += $vm.Name + ','
                         $PoweredOff+=1
             
                         }

                         if ($vm.Network.Count> 1) {
                         Write-Output "VM MultiNetworkServer: $vm.Name"
                         $MultiNetworkServers += $vm.Name + "-" + $vm.Network.ToString() + ','
                          #$vm
                         }

                       

                            if ($vm) {

                                    if ($vm.PowerState  -eq  'PoweredOn') {
                                                #$vm.Site.Name
            
                                                #---Source Infor-----
                                                #$srcSite = Get-HCXSite -Source -Name usd11-bcsvvc001.bmsinfra.net
                                                $srcSite = Get-HCXSite -Source -Name $vm.Site.Name   #$HCXVM.SOURCE_SITE
                                                #$SOURCE_PORTGROUP = "VLAN1189-BAYER-APP-DEV(05)"
                                                $SOURCE_PORTGROUP =  $vm.Network  #$HCXVM.SOURCE_PORTGROUP
                                                $SrcNetwork = Get-HCXNetwork $SOURCE_PORTGROUP -site $srcSite
    
                                                Write-Output " source Network"
                                                $SrcNetwork
        
                                                #---- Desti Info
                                                #$destSite = Get-HCXSite -Destination -Name vc.3e91f884a6774c4ea8de54.eastus.avs.azure.com
                                                $destSite = Get-HCXSite -Destination -Name $HCXVM.DEST_SITE
    
                                                $DESTINATION_PORTGROUP = $HCXVM.DEST_PORTGROUP


                                                $DstNetwork = Get-HCXNetwork   $DESTINATION_PORTGROUP -Site $destSite
   
    
                                                Write-Output " Dest Network"
                                                $DstNetwork

    
                                                #---- Data Store ---
                                                $destDS = Get-HCXDatastore -Name $HCXVM.DEST_DATASTORE -Site $destSite
     
    
                                                #-- Network mapping -----
                                                 Write-Output " Network Mapping"
                                                $NetworkMapping = New-HCXNetworkMapping -SourceNetwork $SrcNetwork  -DestinationNetwork $DstNetwork                                               
                                                $NetworkMapping
                                                #-- EXS  mapping -----
                                                #$EsxServer  = "esx02-r07.p09.3e91f884a6774c4ea8de54.eastus.avs.azure.com"
                                                $EsxServer  = $HCXVM.ESX_SERVER
                                                $destCompute = Get-HCXContainer -Name $EsxServer  -Site $destSite
                                                #Write-Output  "destCompute"
                                                #$destCompute

                                                #cls
                                                #Write-Output "geting network mapping"  

    
    


                                            #    Write-Output " run test mgirationt---->
                                            $newMigration = New-HCXMigration -EnableSeedCheckpoint $True -DestinationSite $destSite -MigrationType RAV -SourceSite $srcSite -TargetComputeContainer $destCompute -TargetDatastore $destDS -NetworkMapping $NetworkMapping -DiskProvisionType 'Thin' -UpgradeVMTools $false -RemoveISOs $true -RetainMac $True -ForcePowerOffVm $false -VM $vm -RemoveSnapshots $True  #-ScheduleStartTime '04/04/2025 11:00:00 AM' -ScheduleEndTime '04/04/2025 11:30:00 AM'
                                            #Start-HCXMigration -Migration $newMigration -Confirm:$false 
                                            Test-HCXMigration -Migration $newMigration
                                   } # vm powered on
                                } # VM exists
                                 else { 
    

                                           
                                            Write-Output  "Error: Missing VM  - " + $HCXVM.SERVER_NAME
    
                                }


               }

         
         
        
        
        } #Try

        catch {
           Write-Output "vm Failed- $($HCXVM).SERVER_NAME -------------------------"
            Write-Output $_.Exception.Message

        }
    
    

$counter +=1;
}

if ($Location -eq 'US') {
#US
Disconnect-HCXServer -Server usd11HCXman -Confirm:$false
} else {
#DE
Disconnect-HCXServer -Server defrHCXman.bayer.cnb -Confirm:$false
}


Write-Host "VM's PoweredOff Count: $PoweredOff"
 
Write-Host "VM's Powered Off: $PoweredOffServers"

Write-Host "VM's Multinetworks: $MultiNetworkServers"

Write-Host "VM's not found: $NotFoundServers"



