cls
Connect-HCXServer -Server usd11HCXman -User 'sutenali' -Password 'UCkJ98}RPU2Yl*U[-?'

write-host(“Import csv details for the VMs to be migrated”)
$HCXVMS = Import-CSV "C:\Temp\Import_VM_list_mobility_Wave1_MG.csv"



ForEach ($HCXVM in $HCXVMS) {


    #Get-HCXMigration
    #$vm = Get-HCXVM -Name  "stlwadlibtst01"
    $vm = Get-HCXVM -Name  $HCXVM.VM_NAME
        
    #---Source Infor-----
    #$srcSite = Get-HCXSite -Source -Name usd11-bcsvvc001.bmsinfra.net
    $srcSite = Get-HCXSite -Source -Name $HCXVM.SOURCE_SITE
    #$SOURCE_PORTGROUP = "VLAN1189-BAYER-APP-DEV(05)"
    $SOURCE_PORTGROUP = $HCXVM.SOURCE_PORTGROUP
    $SrcNetwork = Get-HCXNetwork $SOURCE_PORTGROUP -site $srcSite
        
    #---- Desti Info
    #$destSite = Get-HCXSite -Destination -Name vc.3e91f884a6774c4ea8de54.eastus.avs.azure.com
    $destSite = Get-HCXSite -Destination -Name $HCXVM.DEST_SITE
    #$DESTINATION_PORTGROUP = "L2E_VLAN1189-BAYER-AP-1189-8024c7bc"
    $DESTINATION_PORTGROUP = $HCXVM.DEST_PORTGROUP
    $destNet = Get-HCXNetwork $DESTINATION_PORTGROUP -Site $destSite
    
    
    
    #-- Network mapping -----
    $NetworkMapping = New-HCXNetworkMapping -SourceNetwork $SrcNetwork  -DestinationNetwork $DstNetwork
    #-- EXS  mapping -----
    #$EsxServer  = "esx02-r07.p09.3e91f884a6774c4ea8de54.eastus.avs.azure.com"
    $EsxServer  = $HCXVM.ESX_SERVER
    $destCompute = Get-HCXContainer -Name $EsxServer  -Site $destSite
    

    cls
    Write-Output "geting network mapping"
    $NetworkMapping


    Write-Output " run test mgirationt---->"
$newMigration = New-HCXMigration -DestinationSite $destSite -MigrationType RAV -SourceSite $srcSite -TargetComputeContainer $destCompute -TargetDatastore $destDS -NetworkMapping $NetworkMapping -DiskProvisionType 'Thin' -UpgradeVMTools $false -RemoveISOs $false -RetainMac $True -ForcePowerOffVm $false -VM $vm -ScheduleStartTime '04/03/2025 05:30:00 AM' -ScheduleEndTime '04/03/2025 6:30:00 AM'
#Start-HCXMigration -Migration $newMigration -Confirm:$false 
Test-HCXMigration -Migration $newMigration

}
Disconnect-HCXServer -Server usd11HCXman -Confirm:$false


