cls

Connect-HCXServer -Server usd11HCXman -User 'HCXscriptUser@us-bcs.local' -Password 'Pa$$forCLI2001'

write-host(“Import csv details for the VMs to be migrated”)
#$HCXVMS = Import-CSV "C:\Temp\Import_VM_list_mobility_Wave1_MG.csv"
$HCXVMS = Import-CSV "C:\Temp\Wave2-MobilityGroup_1190.csv"

#$HCXVMS
$counter = 1;
#$MobilityGroupName = "WAVE1_MIG_1189_14thApr";
$MobilityGroupName = "WAVE1_14thApr_" + $(Get-Date).ToString("yyyyMMdd_HHmmss_fff") ;
$startTime = [datetime]::ParseExact("28-04-2025", "dd-MM-yyyy", $null)
$startTime = $startTime.AddHours(3)
Write-Output "--- Frist vm start time --" 
$startTime

#$endTime = $startTime.AddMinutes(30)
$endTime = [datetime]::ParseExact("02-05-2025", "dd-MM-yyyy", $null)
$endTime = $endTime.AddHours(9)
Write-Output "--- Frist vm End time --" 
$endTime

ForEach ($HCXVM in $HCXVMS) {


     try {
             $vm = Get-HCXVM -Name $HCXVM.VM_NAME -ErrorAction SilentlyContinue
             if (!$vm) {
              $vm = Get-HCXVM -Name $($HCXVM.VM_NAME).ToLower()
             }
             Write-Output " ------ VM:$counter - $($($HCXVM.VM_NAME).ToLower())  ------"
             $vm
         
        }

        catch {
           Write-Host "vm Failed- $HCXVM.VM_NAME -------------------------"
           Write-Host $_.Exception.Message

        }

    if ($vm) {
             #$vm.Site.Name
    $MobilityGroupName = "WAVE1_28thApr_test1190_2_" + $vm.Network[0].Name.Replace("(","_").Replace(")","").Replace("-","_").Replace(" ", "");
    $MobilityGroupName     
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
     $destSite
    $DESTINATION_PORTGROUP = $HCXVM.DEST_PORTGROUP


    $DstNetwork = Get-HCXNetwork   $DESTINATION_PORTGROUP -Site $destSite
   
    
    #Write-Output " Dest Network"
    #$DstNetwork

    
    #---- Data Store ---
    $destDS = Get-HCXDatastore -Name vsanDatastore -Site $destSite
     
    
    #-- Network mapping -----
    $NetworkMapping = New-HCXNetworkMapping -SourceNetwork $SrcNetwork  -DestinationNetwork $DstNetwork
    Write-Output  "------NetWork Mapping ---"
    $NetworkMapping


    #------------- MGConfig -------
    
    write-host(“Define Mobility Group Source and Destination Sites”)
    #$NewMGC = New-HCXMobilityGroupConfiguration -SourceSite $srcSite -DestinationSite $destSite -NetworkMapping
    $NewMGC = New-HCXMobilityGroupConfiguration  -SourceSite $srcSite -DestinationSite $destSite -NetworkMapping $NetworkMapping 
    $NewMGC



    #-- EXS  mapping -----
    #$EsxServer  = "esx02-r07.p09.3e91f884a6774c4ea8de54.eastus.avs.azure.com"
    $EsxServer  = $HCXVM.ESX_SERVER
    $destCompute = Get-HCXContainer -Name $EsxServer  -Site $destSite
    #Write-Output  "destCompute"
    #$destCompute


    

      $NewMigration = New-HCXMigration   -VM $vm -NetworkMapping $NetworkMapping  -MigrationType RAV -SourceSite $srcSite -DestinationSite $destSite  -TargetComputeContainer $destCompute -TargetDatastore $destDS -DiskProvisionType Thin -MobilityGroupMigration -RetainMac $True -EnableSeedCheckpoint $True -ScheduleStartTime $startTime -ScheduleEndTime $endTime
      
    
    #This is used the first time to create the mobility group with the required configuration, after the first go it will error saying its already created which is expected
    $mobilityGroup1 = New-HCXMobilityGroup -Name $MobilityGroupName -Migration $NewMigration -GroupConfiguration $NewMGC -ErrorAction SilentlyContinue
 
    #Even though this command will error with "Value cannot be null", it still works and adds each vm to the created mobility group
    Set-HCXMobilityGroup -MobilityGroup (get-hcxmobilitygroup -name $MobilityGroupName) -Migration $NewMigration -addMigration -ErrorAction SilentlyContinue
         

 




 
 
    #Even though this command will error with "Value cannot be null", it still works and adds each vm to the created mobility group
    #Set-HCXMobilityGroup -MobilityGroup (get-hcxmobilitygroup -name $MobilityGroupName) -Migration $NewMigration -addMigration -ErrorAction SilentlyContinue
    Test-HCXMobilityGroup -MobilityGroup (get-hcxmobilitygroup -name $MobilityGroupName)    
    
    #>
    
    }## VM found
    else { 
    

                Write-Output " ------ VM:$counter - $($($HCXVM.VM_NAME).ToLower())  ------"
                Write-Output  "Error: Missing VM  - $($($HCXVM.VM_NAME).ToLower())  "
    
    }
   


#$startTime = $endTime ;
#$endTime = $startTime.AddMinutes(30)
$counter +=1;
}

#This will error with "Value cannot be null" but it will start the migrations of the VMs in the mobility group
#Start-HCXMobilityGroupMigration -MobilityGroup (get-hcxmobilitygroup -name $MobilityGroupName) -ErrorAction SilentlyContinue

Write-Output "--- Last vm end time --" 
$endTime

Disconnect-HCXServer -Server usd11HCXman -Confirm:$false


