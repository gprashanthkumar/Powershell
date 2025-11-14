cls
Connect-HCXServer -Server usd11HCXman -User 'HCXscriptUser@us-bcs.local' -Password 'Pa$$forCLI2001'
$mgs = @()
$mgs+="WAVE1_28thApr_Final_1190_1_VLAN1190_BAYER_APP"
$mgs+="WAVE2_28Apr_Fin_s1_1191_92_VLAN1192_BAYER_APP_DEV"
$mgs+="WAVE2_28Apr_Fin_s2_1191_92_VLAN1192_BAYER_APP_DEV"
$mgs+="WAVE2_28Apr_Fin_s3_1188_89_VLAN1189_BAYER_APP_DEV"
$mgs+="Wave2_DISKFIX_1191_VM_MIG"
$mgs+="WAVE2_28Apr_Fin_s5_1191_VLAN1192_BAYER_APP_DEV"
$mgs+="WAVE2_ColdMigrations"


$mgs
#$MobilityGroupName = "WAVE2_28thApr_Test_1191_92_VLAN1192_BAYER_APP_DEV" # "WAVE1_28thApr_Final_1190_1_VLAN1190_BAYER_APP" 
foreach ($MobilityGroupName  in $mgs) {
    
       #Start-HCXMobilityGroupMigration -MobilityGroup (get-hcxmobilitygroup -name $MobilityGroupName) -ErrorAction SilentlyContinue

    $mgv = get-hcxmobilitygroup -name $MobilityGroupName
        if($mgv) {
         $total = $mgv.TotalMigrations
          Write-Output "Total VM in $MobilityGroupName : $total"
                foreach($x in $mgv.Migration) {
                        "'" + $x.vm.Name +"',"
                        $Query="update  tblWaveVM set  VMOnline =1 , MigrationStatusId =2 where WaveID = 4 and Upper(VMName) = Upper('" + $x.vm.Name +"')"
                        #$Data = Invoke-SQLcmd -ServerInstance BYUS226VXYE -Database "WavesDb" -Query $Query -TrustServerCertificate
                        }
        }

}

Disconnect-HCXServer -Server usd11HCXman -Confirm:$false