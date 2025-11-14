cls
Connect-HCXServer -Server usd11HCXman -User 'sutenali' -Password 'UCkJ98}RPU2Yl*U[-?'

$vm = Get-HCXVM -Name "STLWADLIBTST01"

$destSite = Get-HCXSite -Destination

$srcSite = Get-HCXSite -Source

$destCompute = Get-HCXContainer -Name esx02-r07.p09.3e91f884a6774c4ea8de54.eastus.avs.azure.com  -Site $destSite

#$destDS = Get-HCXDatastore -Name vsanDatastore -Site $destSite
$destDS = Get-HCXDatastore -Name ma-ds-5243b7e6-0a9e5343-2ccd-5ddd417ad1e3 -Site $destSite

$destNet = Get-HCXNetwork -Name L2E_VLAN1189-BAYER-AP-1189-8024c7bc -Site $destSite

$DESTINATION_PORTGROUP = "L2E_VLAN1189-BAYER-AP-1189-8024c7bc"

$SOURCE_PORTGROUP ="VLAN1189-BAYER-APP-DEV(05)"

$DstNetwork = Get-HCXNetwork $DESTINATION_PORTGROUP -site $destSite

#  ""

$SrcNetwork = Get-HCXNetwork $SOURCE_PORTGROUP -site $srcSite

$NetworkMapping = New-HCXNetworkMapping -SourceNetwork $SrcNetwork  -DestinationNetwork $DstNetwork

$ScheduleStart = (Get-Date).AddDays(1);
$ScheduleEnd = (Get-Date).AddDays(2);

 

<#

Write-Output "<----VM---->"

Write-Output $vm

Write-Output "destSite---->"

Write-Output $destSite

Write-Output "src Compute---->"

Write-Output $srcSite

Write-Output "destCompute---->"

Write-Output $destCompute

Write-Output "dest Data store---->"

Write-Output $destDS

Write-Output "dest Net---->"

Write-Output $destNet

 

Write-Output "dest Net NetworkMapping---->"

Write-Output $NetworkMapping

#>

 

<#

Write-Output "SRC SrcNetwork---->"

Write-Output $SrcNetwork

 

 

 

 

Write-Output "dest  DstNetwork---->"

Write-Output $DstNetwork

#>

 

Write-Output "dest Net NetworkMapping---->"

Write-Output $NetworkMapping

 

 

 

 

Write-Output " run test mgirationt---->"

$newMigration = New-HCXMigration -DestinationSite $destSite -MigrationType RAV -SourceSite $srcSite -TargetComputeContainer $destCompute -TargetDatastore $destDS  -DiskProvisionType 'Thin' -UpgradeVMTools $false -RemoveISOs $false -RetainMac $True -ForcePowerOffVm $false -NetworkMapping $NetworkMapping -VM $vm #-ScheduleStartTime $ScheduleStart -ScheduleEndTime $ScheduleEnd

#Start-HCXMigration -Migration $newMigration -Confirm:$false
Test-HCXMigration -Migration $newMigration 