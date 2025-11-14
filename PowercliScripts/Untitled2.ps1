cls
#Connect-VIServer usd11-bcsvvc001 -User 'BMSINFRA\sutenali' -Password 'UCkJ98}RPU2Yl*U[-?'
#Connect-HCXServer -Server usd11HCXman -User 'sutenali' -Password 'UCkJ98}RPU2Yl*U[-?'
$vm = Get-HCXVM -Name "amonwclrmests01"


$destSite = Get-HCXSite -Destination -Name vc.3e91f884a6774c4ea8de54.eastus.avs.azure.com
$srcSite = Get-HCXSite -Source -Name usd11-bcsvvc001.bmsinfra.net
$SOURCE_PORTGROUP = "VLAN1189-BAYER-APP-DEV(05)"
$SrcNetwork = Get-HCXNetwork $SOURCE_PORTGROUP -site $srcSite


$destDS = Get-HCXDatastore -Name vsanDatastore -Site $destSite
$DESTINATION_PORTGROUP = "L2E_VLAN1189-BAYER-AP-1189-8024c7bc"
$destNet = Get-HCXNetwork $DESTINATION_PORTGROUP -Site $destSite
$DstNetwork = Get-HCXNetwork $DESTINATION_PORTGROUP -site $destSite


$NetworkMapping = New-HCXNetworkMapping -SourceNetwork $SrcNetwork  -DestinationNetwork $DstNetwork

$destCompute = Get-HCXContainer -Name esx02-r07.p09.3e91f884a6774c4ea8de54.eastus.avs.azure.com  -Site $destSite

Write-Output " run test mgirationt---->"
$newMigration = New-HCXMigration -DestinationSite $destSite -MigrationType RAV -SourceSite $srcSite -TargetComputeContainer $destCompute -TargetDatastore $destDS -NetworkMapping $NetworkMapping -DiskProvisionType 'Thin' -UpgradeVMTools $false -RemoveISOs $false -RetainMac $True -ForcePowerOffVm $false -VM $vm -ScheduleStartTime '04/03/2025 11:30:00 AM' -ScheduleEndTime '04/03/2025 4:30:00 PM'
#Start-HCXMigration -Migration $newMigration -Confirm:$false 
Test-HCXMigration -Migration $newMigration