cls


# Initialize an empty array
$Wave = "Wave13_"
$array = @()
$servers = @()
$vmsarray = @()
$removeArray =@()
$Location  = "US"



$MGMigratedCount =0;
$ReplicatedCount =0;
$TotalMigrations = 0;
$TotalVMs = 0;
$TotalPercent = '0'
$migstarttime = 0
$migendtime =0
$Period = ""


$Wavefolder = $Wave.Replace(" ","_");
$TableData = ""


$SleepSeconds = 2;
$Output = "";
$WaveOutputFilPath = "C:\Temp\$Wavefolder\VMMigrated_email_" + $(Get-Date).ToString("yymmddHHmmssff") +  ".txt" 
#Note: Handle $Test carefully if set to false emails will go to email-list from database else set to $true
$Test= $true;
$ShowState = $false;




 
 # Sample data

 

#Connect-HCXServer -Server 10.30.164.2 -User 'sutenali' -Password 'UCkJ98}RPU2Yl*U[-?'
if ($Location -eq 'US')  {
 Write-Output "Connecting to  US.......$(Get-Date)"
Connect-HCXServer -Server usd11HCXman -User 'HCXscriptUser@us-bcs.local' -Password 'Pa$$forCLI3001'

} else {
Write-Output "Connecting to  DE.......$(Get-Date)"
Connect-HCXServer -Server defrHCXman.bayer.cnb -User 'HCXscriptUser@de-bcs.local' -Password 'Pa$$forCLI3000'
}

   $mobilityGroups = Get-HCXMobilityGroup
   
    # Display retrieved Mobility Groups
   #$MGSets = $mobilityGroups  | Where-Object {$_.Name.ToUpper().Contains("WAVE10_US_MIG_RAV_1008_09")} 
   $MGSets = $mobilityGroups  | Where-Object {$_.Name.ToUpper().Contains($Wave.ToUpper())} 

   $MGSets = $MGSets | Where-Object {$_.Name -notin $removeArray}

ForEach ($MGSet in $MGSets) {
        #$MGSet
        #$MGSet.Name  +  " - "  + $MGSet.Id + " - " + $MGSet.TotalMigrations
        $MGSet.Name  +  " - "  + $MGSet.TotalMigrations
        $TotalVMs += $MGSet.TotalMigrations

        try {
          
            

                    try {
                               
            
                                   $mobilityGroup = Get-HCXMobilityGroup -Id $MGSet.Id #-Detailed
                                   #$mobilityGroup
                                <#
                                 if($mobilityGroup)  {      
                                       
                                         foreach($migration in ($mobilityGroup.Migration | Sort-Object | Get-Unique)) {
                                                 $migration                        

                                                 $vmsarray += [PSCustomObject]@{ MGSet = $MGSet.Name ;Server = $migration.Name ;}
                                                 $servers += [PSCustomObject]@{Server = $migration.Name ;}                            
                                        }#foreach              
                            
      
                              }
                              #>
       
                         }
        catch {
            Write-Host "Error occurred while retrieving HCX Mobility Groups."
    
            # Display exception message
            Write-Host "Exception: $($_.Exception.Message)"
    
            # Display inner exception details if present
            if ($_.Exception.InnerException) {
                Write-Host "Inner Exception: $($_.Exception.InnerException.Message)"
            }
        }


         $PSDefaultParameterValues['Out-File:Width'] = 2000
        
        
        }
         catch {
          
            Write-Output $_.Exception.Message
            if ($_.Exception.InnerException) {
                Write-Host "Inner Exception: $($_.Exception.InnerException.Message)"
            }

        } 
        # Retrieve the mobility group details
      $vmsarray  | select MGSet,Server |export-csv  "C:\temp\MGSet_servers_data_dummy_$Location.csv" -Delimiter "|" -NoTypeInformation
       
        

       
        
}

 Write-Output "Total  VM in Wave $Wavefolder from  $Location ....... $TotalVMs `n"

if ($Location -eq 'US')  {
    Disconnect-HCXServer -Server usd11HCXman -Confirm:$false
    $Data = Invoke-SQLCmd -ServerInstance BYUS226VXYE -Database "WavesDb" -Query “ exec spImportMGSet_Servers '$Wave' " -TrustServerCertificate 
    
}
else {
    Disconnect-HCXServer -Server defrHCXman.bayer.cnb -Confirm:$false

}
Write-Output "Disconnecting from  $Location .......$(Get-Date)"