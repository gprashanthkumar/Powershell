cls

Connect-HCXServer -Server usd11HCXman -User 'HCXscriptUser@us-bcs.local' -Password 'Pa$$forCLI2001'

write-host(“Import csv details for the VMs to be migrated”)
$HCXVMS = Import-CSV "C:\Temp\Wave-3\Wave-3_MG_US.csv"
#$HCXVMS
$counter = 1;

ForEach ($HCXVM in $HCXVMS) {


     try {
             Write-Output " ------ VM:$counter - $($($HCXVM.VM_NAME).ToLower())  ------"
             $vm = Get-HCXVM -Name $HCXVM.VM_NAME -ErrorAction SilentlyContinue
             if (!$vm) {
              $vm = Get-HCXVM -Name $($HCXVM.VM_NAME).ToLower()
             }             
             $vm
         
        }

        catch {
           Write-Host "vm Failed- $HCXVM.VM_NAME -------------------------"
           Write-Host $_.Exception.Message

        }
    

    #$vm.Site.Name
            
    #---Source Infor-----
    #$srcSite = Get-HCXSite -Source -Name usd11-bcsvvc001.bmsinfra.net
    $srcSite = Get-HCXSite -Source -Name $vm.Site.Name   #$HCXVM.SOURCE_SITE
    #$SOURCE_PORTGROUP = "VLAN1189-BAYER-APP-DEV(05)"
    $SOURCE_PORTGROUP =  $vm.Network  #$HCXVM.SOURCE_PORTGROUP
    $SrcNetwork = Get-HCXNetwork $SOURCE_PORTGROUP -site $srcSite
    
    #$SrcNetwork
        
    #---- Desti Info
    #$destSite = Get-HCXSite -Destination -Name vc.3e91f884a6774c4ea8de54.eastus.avs.azure.com
    $destSite = Get-HCXSite -Destination -Name $HCXVM.DEST_SITE
    
    $DESTINATION_PORTGROUP = $HCXVM.DEST_PORTGROUP


    $DstNetwork = Get-HCXNetwork   $DESTINATION_PORTGROUP -Site $destSite
   
    
    #Write-Output " Dest Network"
    #$DstNetwork

    
    #---- Data Store ---
    $destDS = Get-HCXDatastore -Name "vsanDatastore (1)" -Site $destSite
     
    
    #-- Network mapping -----
    $NetworkMapping = New-HCXNetworkMapping -SourceNetwork $SrcNetwork  -DestinationNetwork $DstNetwork
   # $NetworkMapping
    #-- EXS  mapping -----
    #$EsxServer  = "esx02-r07.p09.3e91f884a6774c4ea8de54.eastus.avs.azure.com"
    $EsxServer  = $HCXVM.ESX_SERVER
    $destCompute = Get-HCXContainer -Name $EsxServer  -Site $destSite
    #Write-Output  "destCompute"
    #$destCompute

    #cls
    #Write-Output "geting network mapping"  

    
    


#    Write-Output " run test mgirationt---->
$newMigration = New-HCXMigration -EnableSeedCheckpoint $True -DestinationSite $destSite -MigrationType RAV -SourceSite $srcSite -TargetComputeContainer $destCompute -TargetDatastore $destDS -NetworkMapping $NetworkMapping -DiskProvisionType 'Thin' -UpgradeVMTools $false -RemoveISOs $false -RetainMac $True -ForcePowerOffVm $false -VM $vm #-ScheduleStartTime '04/04/2025 11:00:00 AM' -ScheduleEndTime '04/04/2025 11:30:00 AM'
#Start-HCXMigration -Migration $newMigration -Confirm:$false 
Test-HCXMigration -Migration $newMigration


$counter +=1;
}

Disconnect-HCXServer -Server usd11HCXman -Confirm:$false


