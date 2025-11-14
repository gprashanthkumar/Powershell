Connect-HCXServer -Server usd11HCXman -User 'HCXscriptUser@us-bcs.local' -Password 'Pa$$forCLI2001'

cls
$vm = Get-HCXVM -Name "amonwclrmests01"
$destSite = Get-HCXSite -Destination -Name vc.3e91f884a6774c4ea8de54.eastus.avs.azure.com
$srcSite = Get-HCXSite -Source -Name usd11-bcsvvc001.bmsinfra.net
$destCompute = Get-HCXContainer -Name esx02-r07.p09.3e91f884a6774c4ea8de54.eastus.avs.azure.com  -Site $destSite
$destDS = Get-HCXDatastore -Name vsanDatastore -Site $destSite
$destNet = Get-HCXNetwork -Name L2E_VLAN1189-BAYER-AP-1189-8024c7bc -Site $destSite
$DESTINATION_PORTGROUP = "L2E_VLAN1189-BAYER-AP-1189-8024c7bc"
$SOURCE_PORTGROUP ="VLAN1189-BAYER-APP-DEV(05)"
$DstNetwork = Get-HCXNetwork $DESTINATION_PORTGROUP -site $destSite
#  ""
$SrcNetwork = Get-HCXNetwork $SOURCE_PORTGROUP -site $srcSite
$NetworkMapping = New-HCXNetworkMapping -SourceNetwork $SrcNetwork  -DestinationNetwork $DstNetwork



Write-Output " run test mgirationt---->"
$newMigration = New-HCXMigration -DestinationSite $destSite -MigrationType RAV -SourceSite $srcSite -TargetComputeContainer $destCompute -TargetDatastore $destDS  -DiskProvisionType 'Thin' -UpgradeVMTools $false -RemoveISOs $false -RetainMac $True -ForcePowerOffVm $false -NetworkMapping $NetworkMapping -VM $vm 
#Start-HCXMigration -Migration $newMigration -Confirm:$false 
Test-HCXMigration -Migration $newMigration